#!/usr/bin/env python3

import argparse
import logging
import sys
import subprocess
from typing import List, Optional

from utils.file_utils import find_spec_file, is_valid_ruby_file  # Changed import
from utils.aider_client import AiderClient, CODE_MODEL


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
        description="Generate RSpec unit tests for Ruby files using aider."
    )
    parser.add_argument(
        "ruby_file", type=str, help="Path to the Ruby file for which to generate tests."
    )
    parser.add_argument(
        "--spec-file",
        type=str,
        help="Path to the corresponding spec file (optional). If not provided, attempts to find it.",
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
        default=CODE_MODEL,  # Defaulting to a capable model
        help='The language model to use (e.g., "gpt-4o", "o3-mini").',
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
    """Main function to orchestrate test generation."""
    args = parse_arguments()

    if not is_valid_ruby_file(args.ruby_file):
        logger.error(f"Invalid Ruby file provided: {args.ruby_file}")
        sys.exit(1)

    ruby_file_path = args.ruby_file
    spec_file_path: Optional[str] = args.spec_file

    if not spec_file_path:
        logger.info(f"Attempting to find spec file for {ruby_file_path}...")
        try:
            spec_file_path = find_spec_file(ruby_file_path)
            if spec_file_path:
                logger.info(f"Found spec file: {spec_file_path}")
            else:
                logger.warning(
                    f"Could not automatically find a spec file for {ruby_file_path}. "
                    "Aider will attempt to create one if necessary, or you can provide one with --spec-file."
                )
        except ValueError as e:
            logger.error(f"Error finding spec file: {e}")
            # Continue without a spec file, aider might create one
            spec_file_path = None

    aider_client = AiderClient(aider_path=args.aider_path)

    try:
        logger.info(f"Generating tests for {ruby_file_path}...")
        output = aider_client.generate_tests(
            ruby_file=ruby_file_path,
            spec_file=spec_file_path,
            additional_files=args.additional_files,
            model=args.model,
            stream=args.stream,
            auto_commits=args.auto_commits,
            dry_run=args.dry_run,
            yes=args.yes,
        )

        logger.info("Aider command executed successfully.")
        logger.info("Aider output:")
        print(output)  # Print aider's raw output
        if args.dry_run:
            logger.info("Dry run complete. No files were modified.")
        else:
            logger.info(
                "Test generation process complete. Check the specified Ruby and spec files for changes."
            )

    except FileNotFoundError:
        logger.error(
            "Aider executable not found. Please ensure it's installed and in your PATH or specify with --aider-path."
        )
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        logger.error(f"Aider command failed: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
