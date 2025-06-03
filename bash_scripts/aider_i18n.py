#!/usr/bin/env python3

import argparse
import logging
import sys
import subprocess
from typing import List, Optional
from pathlib import Path  # Added for sys.path modification

# Add project root to sys.path to allow absolute imports from 'bash_scripts'
# Assumes this script is in '.../dotfiles/bash_scripts/aider_i18n.py'
# so, Path(__file__).resolve().parent is '.../dotfiles/bash_scripts'
# and Path(__file__).resolve().parent.parent is '.../dotfiles'
_project_root = Path(__file__).resolve().parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

from bash_scripts.utils.aider_client import (
    AiderClient,
    CODE_MODEL,
)  # Changed to absolute import
from bash_scripts.utils.file_utils import (
    is_valid_ruby_file,
)  # Changed to absolute import

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)


def parse_arguments() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate i18n YAML translations for Ruby ViewComponent files using aider."
    )
    parser.add_argument(
        "view_component_file",
        type=str,
        help="Path to the Ruby ViewComponent file (e.g., app/components/my_component.rb).",
    )
    parser.add_argument(
        "--languages",
        type=str,
        nargs="+",
        default=["en", "pt-BR", "fr"],
        help="List of language codes to generate translations for (e.g., en pt-BR fr).",
    )
    parser.add_argument(
        "--output-yml-file",
        type=str,
        help="Path to the output .yml file for translations. If not provided, defaults to a companion .yml file.",
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
    return parser.parse_args()


def main():
    """Main function to orchestrate translation generation."""
    args = parse_arguments()

    if not is_valid_ruby_file(args.view_component_file):
        logger.error(
            f"Invalid Ruby file provided for ViewComponent: {args.view_component_file}"
        )
        sys.exit(1)

    aider_client = AiderClient(aider_path=args.aider_path)

    try:
        logger.info(
            f"Generating translations for {args.view_component_file} into languages: {', '.join(args.languages)}..."
        )
        output = aider_client.generate_translations(
            view_component_file=args.view_component_file,
            languages=args.languages,
            output_yml_file=args.output_yml_file,
            additional_files=args.additional_files,
            model=args.model,
            stream=args.stream,
            auto_commits=args.auto_commits,
            dry_run=args.dry_run,
            yes=args.yes,
        )

        logger.info("Aider command for translations executed successfully.")
        logger.info("Aider output:")
        print(output)  # Print aider's raw output
        if args.dry_run:
            logger.info("Dry run complete. No files were modified.")
        else:
            logger.info(
                "Translation generation process complete. Check the specified component and YML files for changes."
            )

    except FileNotFoundError as e:
        # This could be aider executable not found OR companion HAML not found
        if (
            "Aider executable not found" in str(e)
            or "No such file or directory" in str(e).lower()
            and args.aider_path in str(e)
        ):
            logger.error(
                f"Aider executable not found at '{args.aider_path}'. Please ensure it's installed and in your PATH or specify with --aider-path."
            )
        elif "Companion HAML file" in str(e):
            logger.error(f"Failed to generate translations: {e}")
        else:
            logger.error(f"File not found error: {e}")
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
