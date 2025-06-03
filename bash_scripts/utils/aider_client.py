import subprocess
import logging
from typing import List, Optional
from pathlib import Path

logger = logging.getLogger(__name__)

# CODE_MODEL = "azure/gpt-4.1"
CODE_MODEL = "azure/o4-mini"  # Defaulting to a capable model for code generation

DO_NOT_FOLLOW_UP_COMMENT = (
    "All of this is straigghtforward. Do now ask follow-up questions, just do it. "
)


class AiderClient:
    """
    A client for interacting with the aider CLI.
    """

    def __init__(self, aider_path: str = "aider"):
        """
        Initializes the AiderClient.

        Args:
            aider_path: The path to the aider executable.
        """
        self.aider_path = aider_path

    def _execute_command(self, command: List[str]) -> str:
        """
        Executes an aider command and returns the output.

        Args:
            command: The aider command to execute as a list of strings.

        Returns:
            The stdout from the command execution.

        Raises:
            subprocess.CalledProcessError: If the command returns a non-zero exit code.
        """
        try:
            logger.info(f"Executing aider command NOW: {' '.join(command)}")
            process = subprocess.run(
                command, capture_output=True, text=True, check=True
            )
            logger.debug(f"Aider command stdout:\n{process.stdout}")
            if process.stderr:
                logger.warning(f"Aider command stderr:\n{process.stderr}")
            return process.stdout
        except subprocess.CalledProcessError as e:
            logger.error(f"Aider command failed with exit code {e.returncode}")
            logger.error(f"Stdout: {e.stdout}")
            logger.error(f"Stderr: {e.stderr}")
            raise
        except FileNotFoundError:
            logger.error(
                f"Aider executable not found at '{self.aider_path}'. "
                "Please ensure aider is installed and in your PATH, or provide the correct path."
            )
            raise

    def generate_tests(
        self,
        ruby_file: str,
        spec_file: Optional[str] = None,
        additional_files: Optional[List[str]] = None,
        model: str = CODE_MODEL,  # Defaulting to a capable model
        stream: bool = True,
        auto_commits: bool = False,  # Defaulting to no auto-commits for more control
        dry_run: bool = False,
        yes: bool = True,  # Automatically confirm prompts
    ) -> str:
        """
        Generates unit tests for a given Ruby file using aider.

        Args:
            ruby_file: Path to the Ruby file.
            spec_file: Path to the corresponding spec file (optional).
                       If provided, aider will also consider this file.
            additional_files: List of other relevant files to include in aider's context.
            model: The language model to use (e.g., "gpt-4o", "o3-mini").
            stream: Whether to stream responses.
            auto_commits: Whether to enable auto-commits.
            dry_run: Whether to perform a dry run.
            yes: Whether to automatically say yes to confirmations.

        Returns:
            The output from the aider command.
        """
        command = [self.aider_path]

        files_to_include = [ruby_file]
        if spec_file:
            files_to_include.append(spec_file)
        if additional_files:
            files_to_include.extend(additional_files)

        for f_path in files_to_include:
            command.extend(["--file", f_path])

        command.extend(["--model", model])
        command.extend(["--weak-model", model])
        command.extend(["--reasoning-effort", "high"])

        if stream:
            command.append("--stream")
        else:
            command.append("--no-stream")

        if auto_commits:
            command.append("--auto-commits")
        else:
            command.append("--no-auto-commits")  # Explicitly disable for safety

        if dry_run:
            command.append("--dry-run")

        if yes:
            command.append("--yes")

        # The core instruction for aider
        ruby_file_name = Path(ruby_file).name
        spec_file_name_for_prompt = Path(spec_file).name if spec_file else "new_spec.rb"
        message = (
            f"Generate comprehensive RSpec unit tests for the Ruby file '{ruby_file_name}'. "
            f"Ensure the tests cover all complex public methods and edge cases. "
            f"If a spec file ('{spec_file_name_for_prompt}') is provided or implied, "
            f"add the new tests to it, or create it if it doesn't exist. "
            f"Focus on creating relevant and robust tests. "
            f"#{DO_NOT_FOLLOW_UP_COMMENT}"
        )
        command.extend(["--message", message])

        return self._execute_command(command)

    def generate_component(
        self,
        view_component_path: str,
        controller_action_path: str,  # e.g., "users#show"
        additional_files: Optional[List[str]] = None,
        model: str = CODE_MODEL,
        stream: bool = True,
        auto_commits: bool = False,
        dry_run: bool = False,
        yes: bool = True,
    ) -> str:
        """
        Generates or updates a ViewComponent and its HAML template using aider.

        Args:
            view_component_path: Path to the Ruby ViewComponent file (e.g., 'app/components/users/profile_component.rb').
                                 This file will be created or updated by aider.
            controller_action_path: String indicating the controller and action for context (e.g., 'users#show').
            additional_files: List of other relevant files to include in aider's context
                              (e.g., the controller file or the original action view).
            model: The language model to use.
            stream: Whether to stream responses.
            auto_commits: Whether to enable auto-commits.
            dry_run: Whether to perform a dry run.
            yes: Whether to automatically say yes to confirmations.

        Returns:
            The output from the aider command.
        """
        command = [self.aider_path]

        component_rb_path = Path(view_component_path)
        component_haml_path = component_rb_path.with_suffix(".html.haml")
        view_path = [
            x for x in additional_files if x.endswith(".haml") or x.endswith(".erb")
        ][0]

        # These files are the primary targets for aider. Aider will create them if they don't exist.
        files_to_include = [str(component_rb_path), str(component_haml_path)]

        if additional_files:
            # Ensure additional files are strings, as Path objects might be passed
            files_to_include.extend([str(f) for f in additional_files])

        for f_path in files_to_include:
            command.extend(["--file", f_path])

        command.extend(["--model", model])
        command.extend(["--weak-model", model])

        if stream:
            command.append("--stream")
        else:
            command.append("--no-stream")

        if auto_commits:
            command.append("--auto-commits")
        else:
            command.append("--no-auto-commits")

        if dry_run:
            command.append("--dry-run")

        if yes:
            command.append("--yes")

        component_rb_filename = component_rb_path.name
        component_haml_filename = component_haml_path.name

        message = (
            f"We are moving logic from rails view/controller to a ViewComponent. "
            f"Create the ViewComponent defined in '{component_rb_filename}' and its corresponding HAML template '{component_haml_filename}'. "
            f"This component is intended to replace the logic and view code from the '{controller_action_path}' controller action. "
            f"Ensure the Ruby component class in '{component_rb_filename}' is well-structured, accepts necessary parameters, and "
            f"extracts the view-related controller logic into methods as needed "
            f"(do not migrate redirect logic, of course). "
            f"Also ensure the HAML file in '{component_haml_filename}' is valid and reflects exactly the same code (including comments, if any) from the file '{view_path}'. "
            f'Do not forget to update the controller file, removing the code moved to the component and rendering it like "render ComponentClass.new(...)".'
            f"#{DO_NOT_FOLLOW_UP_COMMENT}"
        )
        command.extend(["--message", message])
        print(">>>>>")
        print(">>>>>")
        print(files_to_include)
        print(f"Executing command: {' '.join(command)}")
        print(">>>>>")
        print(">>>>>")

        return self._execute_command(command)

    def generate_translations(
        self,
        view_component_file: str,
        languages: List[str],
        output_yml_file: Optional[str] = None,
        additional_files: Optional[List[str]] = None,
        model: str = CODE_MODEL,
        stream: bool = True,
        auto_commits: bool = False,
        dry_run: bool = False,
        yes: bool = True,
    ) -> str:
        """
        Generates i18n translation YAML for a given ViewComponent file and its HAML template.

        Args:
            view_component_file: Path to the Ruby ViewComponent file (e.g., 'app/components/my_component.rb').
            languages: List of language codes to generate translations for (e.g., ['en', 'pt-BR']).
            output_yml_file: Path to the .yml file where translations should be stored.
                             If None, defaults to a companion .yml file in the same directory as the
                             view_component_file (e.g., 'app/components/my_component.yml').
            additional_files: List of other relevant files to include in aider's context.
            model: The language model to use.
            stream: Whether to stream responses.
            auto_commits: Whether to enable auto-commits.
            dry_run: Whether to perform a dry run.
            yes: Whether to automatically say yes to confirmations.

        Returns:
            The output from the aider command.

        Raises:
            FileNotFoundError: If the companion HAML file is not found.
        """
        command = [self.aider_path]

        component_path = Path(view_component_file)
        haml_file_path = component_path.with_suffix(".html.haml")

        if not haml_file_path.is_file():
            logger.error(
                f"Companion HAML file not found at expected path: {haml_file_path}"
            )
            raise FileNotFoundError(
                f"Companion HAML file '{haml_file_path}' for ViewComponent '{view_component_file}' not found. "
                "This file is required for generating translations."
            )

        files_to_include = [view_component_file, str(haml_file_path)]

        # Determine output YML file path
        if output_yml_file:
            output_yml_file_path = Path(output_yml_file)
        else:
            output_yml_file_path = component_path.with_suffix(".yml")
            logger.info(
                f"Output YML file not specified, defaulting to: {output_yml_file_path}"
            )

        files_to_include.append(str(output_yml_file_path))

        if additional_files:
            files_to_include.extend(additional_files)

        for f_path in files_to_include:
            command.extend(["--file", str(f_path)])

        command.extend(["--model", model])
        command.extend(["--weak-model", model])
        command.extend(["--reasoning-effort", "high"])

        if stream:
            command.append("--stream")
        else:
            command.append("--no-stream")

        if auto_commits:
            command.append("--auto-commits")
        else:
            command.append("--no-auto-commits")

        if dry_run:
            command.append("--dry-run")

        if yes:
            command.append("--yes")

        view_component_filename = component_path.name
        haml_filename = haml_file_path.name
        output_yml_filename = output_yml_file_path.name

        component_scope_key = (
            component_path.stem
        )  # e.g., "my_component" from "my_component.rb"
        languages_str = ", ".join(languages)

        example_lang1 = languages[0]
        example_lang2_part = ""
        if len(languages) > 1:
            example_lang2_part = (
                f"{languages[1]}:\n"
                f"  {component_scope_key}:\n"
                f'    example_key: "Translated example text in {languages[1]}"\n'
            )
        else:
            example_lang2_part = f"# (Translations for other specified languages would follow a similar pattern)\n"

        message = (
            f"Analyze the ViewComponent file '{view_component_filename}' and its corresponding HAML template '{haml_filename}'. "
            f"Extract all user-facing strings that require internationalization (i18n). "
            f"For each extracted string, generate appropriate translation keys and their translations "
            f"for the following languages: {languages_str}. "
            f"Organize these translations into the YAML file '{output_yml_filename}'. "
            f"The YAML structure should follow standard Rails i18n conventions, grouping translations by language code "
            f"at the top level. Within each language, use the root scope (no need to use the component name), and nest if you see fit."
            f"As an example, if a string 'Original Text' is found, its translation key might be 'original_text' or similar:\n"
            f"{example_lang1}:\n"
            f"  original_text: \"Translated 'Original Text' in {example_lang1}\"\n"
            f"{example_lang2_part}"
            f"Ensure the generated YAML is valid and updates or creates '{output_yml_filename}' correctly. "
            f"If '{output_yml_filename}' already exists, intelligently merge the new translations, "
            f"preserving existing content and structure where possible."
            f'Update the haml (and/or erb) file(s) using the helper method, e.g. t(".original_text"), '
            f"#{DO_NOT_FOLLOW_UP_COMMENT}"
        )
        command.extend(["--message", message])

        return self._execute_command(command)
