#!/usr/bin/env python3

import argparse
import logging
import sys
import subprocess
from typing import List, Optional
from pathlib import Path
import time

# Add project root to sys.path to allow absolute imports
_project_root = Path(__file__).resolve().parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

from bash_scripts.utils.aider_client import (
    AiderClient,
    CODE_MODEL,
)
from bash_scripts.utils.file_utils import (
    is_valid_ruby_file,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)


def find_rails_root(start_path: Path) -> Optional[Path]:
    """Tries to find the Rails project root by looking for Gemfile and config/application.rb."""
    current_path = start_path.resolve()
    # Iterate upwards from the start_path's directory
    if current_path.is_file():
        current_path = current_path.parent

    while current_path != current_path.parent:  # Stop at filesystem root
        if (current_path / "Gemfile").is_file() and (
            current_path / "config" / "application.rb"
        ).is_file():
            return current_path
        current_path = current_path.parent
    return None


def parse_arguments() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Improve ViewComponent aesthetics using aider and a component snapshot."
    )
    parser.add_argument(
        "view_component_file",
        type=str,
        help="Path to the Ruby ViewComponent file (e.g., app/components/my_component.rb).",
    )
    parser.add_argument(
        "--image-file",
        type=str,
        help="Path to an existing image of the component. If provided, rake task will be skipped.",
    )

    parser.add_argument(
        "--skip-rake-task",
        action="store_true",
        help="Skip the rake task for generating component image. Assumes image exists.",
    )
    parser.add_argument(
        "--rake-task-arg",
        type=str,
        default="",
        help="Additional argument for the rake task (e.g., namespace).",
    )

    parser.add_argument(
        "--additional-files",
        type=str,
        nargs="*",
        help="List of other relevant files to include in aider's context.",
    )
    parser.add_argument(
        "--model",
        type=str,
        default=CODE_MODEL,  # Ensure this model supports vision, e.g., gpt-4o
        help=f"The language model to use (e.g., 'gpt-4o'). Default: {CODE_MODEL}.",
    )
    parser.add_argument(
        "--aider-path",
        type=str,
        default="aider",
        help="Path to the aider executable.",
    )
    parser.add_argument(
        "--no-stream",
        action="store_false",
        dest="stream",
        help="Disable streaming responses from aider.",
    )
    parser.add_argument(
        "--auto-commits",
        action="store_true",
        help="Enable auto-commits by aider.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform a dry run without modifying files.",
    )
    parser.add_argument(
        "--no-auto-yes",
        action="store_false",
        dest="yes",
        help="Disable automatically saying yes to aider confirmations.",
    )
    return parser.parse_args()


def main():
    """Main function to orchestrate component prettification."""
    args = parse_arguments()

    component_rb_path = Path(args.view_component_file)
    if not is_valid_ruby_file(str(component_rb_path)):
        logger.error(
            f"Invalid Ruby file provided for ViewComponent: {component_rb_path}"
        )
        sys.exit(1)

    component_haml_path = component_rb_path.with_suffix(".html.haml")
    if not component_haml_path.is_file():
        logger.error(
            f"Companion HAML file not found at expected path: {component_haml_path}"
        )
        sys.exit(1)

    rails_root = find_rails_root(component_rb_path)
    if not rails_root:
        logger.warning(
            f"Could not determine Rails project root from '{component_rb_path}'. "
            "Rake task CWD might be incorrect. Assuming current directory or that 'bundle exec' resolves."
        )
        # Proceeding with cwd=None for rake, or user must ensure environment is correct
        # Alternatively, could make rails_root a required discovery or arg.
        # For now, we'll let it try. If rake fails, it will be caught.
        effective_cwd_for_rake = None
    else:
        logger.info(f"Determined Rails project root: {rails_root}")
        effective_cwd_for_rake = rails_root

    actual_image_path_str: Optional[str] = None

    if args.image_file:
        actual_image_path_str = args.image_file
        logger.info(f"Using provided image file: {actual_image_path_str}")
        if not Path(actual_image_path_str).is_file():
            logger.error(f"Provided image file not found: {actual_image_path_str}")
            sys.exit(1)
    else:
        # Derive image name: e.g., my_component.rb -> my_component.png
        # This is a heuristic. Lookbook might use more complex naming.
        # The rake task argument might also influence the output name.
        image_base_name = component_rb_path.stem
        # If component is app/components/namespace/my_component.rb, stem is "my_component"
        # Rake task might generate "namespace_my_component.png"
        # For simplicity, we'll use a direct stem and let user override with --image-file if needed.
        # A more robust solution might involve parsing rake output or having stricter naming conventions.
        expected_image_filename = (
            f"{image_base_name}.png"  # Assuming PNG, could be configurable
        )

        if not args.skip_rake_task:
            component_name = (
                str(component_rb_path).split("/")[-1].replace("_component.rb", "")
            )
            rake_task_target = (
                args.rake_task_arg if args.rake_task_arg else component_name
            )
            print(
                f"Running rake task to generate component image for: {rake_task_target}"
            )
            rake_command = [
                "bin/rake",
                f"lookbook_visual_tester:images[{rake_task_target}]",
            ]
            logger.info(
                f"Executing rake task: {' '.join(rake_command)} in CWD: {effective_cwd_for_rake or Path.cwd()}"
            )

            try:
                process = subprocess.Popen(
                    rake_command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    cwd=effective_cwd_for_rake,
                )
                try:
                    stdout, stderr = process.communicate(timeout=60)
                except subprocess.TimeoutExpired:
                    process.kill()
                    stdout, stderr = process.communicate()
                    logger.error("Rake task timed out after 60 seconds.")
                    sys.exit(1)
                process.stdout = stdout
                process.stderr = stderr
                process.returncode = process.returncode
                if process.returncode != 0:
                    logger.error(
                        f"Rake task failed with exit code {process.returncode}"
                    )
                    logger.error(f"Rake stdout:\n{process.stdout}")
                    logger.error(f"Rake stderr:\n{process.stderr}")
                    sys.exit(1)
                logger.info("Rake task completed successfully.")
                logger.info(f"Rake stdout:\n{process.stdout}")

                actual_image_path_str = str(process.stdout)

                if process.stderr:
                    logger.warning(f"Rake stderr:\n{process.stderr}")

            except FileNotFoundError:
                logger.error(
                    "Failed to run 'bundle exec rake'. Ensure Bundler and Rake are installed and Rails environment is set up."
                )
                sys.exit(1)
            except Exception as e:
                logger.error(f"Error during rake task execution: {e}")
                sys.exit(1)
        else:
            logger.info("Skipping rake task as per --skip-rake-task.")
        # if not Path(actual_image_path_str).is_file():
        #     time.sleep(1)  # Give some time for the file to be created
        #     logger.error(
        #         f"Expected image file not found after rake task (or skipped): {actual_image_path_str}. "
        #         "Ensure the rake task `lookbook_visual_tester:images` ran correctly and produced this file, "
        #         "or that the file exists if skipping the task. "
        #         "You might need to use --image-file to specify the correct path if the naming convention differs."
        #     )
        #     sys.exit(1)
        logger.info(f"Using image file for Aider: {actual_image_path_str}")

    aider_client = AiderClient(aider_path=args.aider_path)

    try:
        logger.info(
            f"Asking Aider to prettify {component_rb_path.name} using image {Path(actual_image_path_str).name}..."
        )
        output = aider_client.prettify_component(
            component_rb_file=str(component_rb_path),
            component_haml_file=str(component_haml_path),
            image_file=actual_image_path_str,
            additional_files=args.additional_files,
            model=args.model,
            stream=args.stream,
            auto_commits=args.auto_commits,
            dry_run=args.dry_run,
            yes=args.yes,
        )

        logger.info("Aider command for prettifying executed.")
        logger.info("Aider output:")
        print(output)
        if args.dry_run:
            logger.info("Dry run complete. No files were modified.")
        else:
            logger.info(
                "Prettification process complete. Check the component Ruby and HAML files for changes."
            )

    except FileNotFoundError as e:
        if args.aider_path in str(e):
            logger.error(
                f"Aider executable not found at '{args.aider_path}'. Please ensure it's installed and in your PATH or specify with --aider-path."
            )
        else:
            logger.error(f"File not found error during Aider execution: {e}")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        logger.error(
            f"Aider command failed: {e.returncode}\nStdout: {e.stdout}\nStderr: {e.stderr}"
        )
        sys.exit(1)
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
