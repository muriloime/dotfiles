#!/usr/bin/env python3

import argparse
import logging
import sys
import subprocess
from typing import List, Optional, Tuple
from pathlib import Path
import os

# Add project root to sys.path to allow absolute imports from 'bash_scripts'
_project_root = Path(__file__).resolve().parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

_rails_root = Path(os.getcwd())

from bash_scripts.utils.aider_client import AiderClient, CODE_MODEL
from bash_scripts.utils.file_utils import (
    is_valid_ruby_file,
)  # For validating component file path


DEFAULT_COMPONENT_PATH = "app/components"

VIEW_EXTENSIONS = [
    ".html.haml",
    ".html.erb",
    ".haml",
    ".erb",
    ".html.slim",
    ".slim",
]

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)


def find_rails_context_files(
    controller_action_path: str, project_root_str: str
) -> List[str]:
    """
    Finds conventional Rails controller and view files based on a controller#action string.
    Assumes a standard Rails project structure relative to the provided project_root.

    Args:
        controller_action_path: The controller and action (e.g., "users#show", "admin/posts#edit").
        project_root_str: The string path to the Rails project root.

    Returns:
        A list of existing file paths (as strings) for the controller and view.
    """
    found_files: List[str] = []
    project_root = Path(project_root_str)  # Typically _project_root from the script

    try:
        controller_part, action_part = controller_action_path.split("#", 1)
    except ValueError:
        logger.warning(
            f"Invalid controller_action_path format: '{controller_action_path}'. Expected 'controller#action'."
        )
        return found_files

    # Controller file
    # e.g., "users" -> "app/controllers/users_controller.rb"
    # e.g., "admin/users" -> "app/controllers/admin/users_controller.rb"
    controller_file_path = (
        project_root / "app" / "controllers" / f"{controller_part}_controller.rb"
    )
    if controller_file_path.is_file():
        found_files.append(str(controller_file_path))
        logger.info(f"Found context controller file: {controller_file_path}")
    else:
        logger.info(f"Context controller file not found at: {controller_file_path}")

    # View file
    # e.g., "users#show" -> "app/views/users/show.html.haml" (or .erb, etc.)
    # e.g., "admin/users#index" -> "app/views/admin/users/index.html.haml"
    view_dir_path = project_root / "app" / "views" / controller_part

    view_file_found = False
    for ext in VIEW_EXTENSIONS:
        view_file_path = view_dir_path / f"{action_part}{ext}"
        if view_file_path.is_file():
            found_files.append(str(view_file_path))
            logger.info(f"Found context view file: {view_file_path}")
            view_file_found = True
            break
    if not view_file_found:
        logger.info(
            f"Context view file not found in {view_dir_path} for action '{action_part}' with common extensions."
        )
    if len(found_files) < 2:
        raise FileNotFoundError(
            f"Could not find sufficient context files for '{controller_action_path}'. "
            "Ensure the controller and view files follow Rails conventions."
        )
    return found_files


def parse_arguments() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate or update a Ruby ViewComponent and its HAML template using aider."
    )
    parser.add_argument(
        "view_component_path",
        type=str,
        help="Path to the Ruby ViewComponent file (e.g., app/components/users/profile_component.rb). This file will be created or updated.",
    )
    parser.add_argument(
        "controller_action_path",
        type=str,
        help="Controller and action path for context (e.g., 'users#show' or 'admin/reports#index').",
    )
    parser.add_argument(
        "--additional-files",
        type=str,
        nargs="*",
        default=[],  # Initialize with an empty list
        help="List of other relevant files to include in aider's context (e.g., the controller file, original view template).",
    )
    parser.add_argument(
        "--model",
        type=str,
        default=CODE_MODEL,
        help='The language model to use (e.g., "gpt-4o", "azure/gpt-4.1").',
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
    parser.add_argument(
        "--no-auto-context-files",
        action="store_true",
        help="Disable automatically finding and adding controller/view files to context.",
    )
    return parser.parse_args()


def convert_class_to_path(class_name: str) -> str:
    """
    Converts a class name in the format 'Namespace::ClassName' to a file path.
    For example, 'Users::ProfileComponent' becomes 'users/profile_component.rb'.

    Args:
        class_name: The class name to convert.

    Returns:
        A string representing the file path.
    """
    parts = class_name.split("::")

    def camel_to_snake_case(part: str) -> str:
        """Converts CamelCase to snake_case."""
        return "".join(["_" + c.lower() if c.isupper() else c for c in part]).lstrip(
            "_"
        )

    file_path = "/".join(camel_to_snake_case(part) for part in parts) + ".rb"
    return file_path


def main():
    """Main function to orchestrate ViewComponent generation/update."""
    args = parse_arguments()

    if "::" in args.view_component_path:
        args.view_component_path = convert_class_to_path(args.view_component_path)

    # Basic validation for the component path (must end with .rb)
    if not args.view_component_path.endswith(".rb"):
        args.view_component_path += ".rb"

    if DEFAULT_COMPONENT_PATH not in args.view_component_path:
        args.view_component_path = (
            DEFAULT_COMPONENT_PATH + "/" + args.view_component_path
        )

    # Validate controller_action_path format (simple check for '#')
    if "#" not in args.controller_action_path:
        logger.error(
            f"Invalid controller_action_path format: '{args.controller_action_path}'. Expected format 'controller#action'."
        )
        sys.exit(1)

    current_additional_files = list(args.additional_files)  # Make a mutable copy

    if not args.no_auto_context_files:
        logger.info(
            f"Attempting to find Rails context files for '{args.controller_action_path}'..."
        )
        # Assuming _project_root (defined globally) is the Rails project root.
        # This might need adjustment if the script is run from outside the project or if CWD is different.
        # For now, we use the script's parent's parent as the project root.
        rails_context_files = find_rails_context_files(
            args.controller_action_path, str(_rails_root)
        )
        for f_path in rails_context_files:
            if f_path not in current_additional_files:
                current_additional_files.append(f_path)
                logger.info(f"Automatically added to context: {f_path}")
    else:
        logger.info("Automatic context file finding disabled by user.")

    aider_client = AiderClient(aider_path=args.aider_path)

    try:
        logger.info(
            f"Generating/updating ViewComponent '{args.view_component_path}' "
            f"with context from '{args.controller_action_path}'..."
        )
        if current_additional_files:
            logger.info(
                f"Using additional context files: {', '.join(current_additional_files)}"
            )

        output = aider_client.generate_component(
            view_component_path=args.view_component_path,
            controller_action_path=args.controller_action_path,
            additional_files=current_additional_files,
            model=args.model,
            stream=args.stream,
            auto_commits=args.auto_commits,
            dry_run=args.dry_run,
            yes=args.yes,
        )
        # Delete  the file in view_file_path
        for file_path in rails_context_files:
            if any(extension in file_path for extension in VIEW_EXTENSIONS):
                os.remove(file_path)
                # Log the deletion
                logger.info(f"Deleted view file: {file_path}")

        logger.info(
            "Aider command for component generation/update executed successfully."
        )
        logger.info("Aider output:")
        print(output)
        if args.dry_run:
            logger.info("Dry run complete. No files were modified.")
        else:
            logger.info(
                "ViewComponent generation/update process complete. Check the specified files for changes."
            )

    except FileNotFoundError as e:
        # This primarily catches aider executable not found
        logger.error(
            f"Aider executable not found at '{args.aider_path}'. Please ensure it's installed and in your PATH or specify with --aider-path."
        )
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
