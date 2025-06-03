import os
import re
from pathlib import Path
from typing import Optional


def find_spec_file(ruby_file_path: str) -> Optional[str]:
    """
    Finds the corresponding spec file for a given Ruby file path.

    Args:
        ruby_file_path: The absolute or relative path to the Ruby file.

    Returns:
        The path to the spec file if found, otherwise None.
    """
    p = Path(ruby_file_path).resolve()
    filename = p.name

    if not filename.endswith(".rb"):
        raise ValueError(f"'{ruby_file_path}' is not a Ruby file.")

    if "app/" not in str(p):
        # Attempt to find spec file for non-standard paths (e.g. lib/)
        # This assumes spec file is in a parallel 'spec' directory
        # e.g. lib/foo/bar.rb -> spec/lib/foo/bar_spec.rb
        relative_path_from_project_root: Path
        if "lib" in p.parts:
            # Find the first occurrence of 'lib' and take parts from there
            lib_index = p.parts.index("lib")
            path_parts_from_lib = p.parts[lib_index:]
            relative_path_from_project_root = Path(*path_parts_from_lib)
        else:
            # If 'lib' is not in path, use the filename as the base for relative path
            relative_path_from_project_root = Path(p.name)
        spec_file_name = f"{p.stem}_spec.rb"

        # Search upwards for a 'spec' directory
        current_dir = p.parent
        while current_dir != current_dir.parent:  # Stop at root
            spec_dir_candidate = current_dir / "spec"
            if spec_dir_candidate.is_dir():
                potential_spec_path = (
                    spec_dir_candidate
                    / relative_path_from_project_root.parent
                    / spec_file_name
                )
                if potential_spec_path.exists():
                    return str(potential_spec_path)
            current_dir = current_dir.parent
        return None

    # Standard Rails app/ structure
    # e.g. app/models/user.rb -> spec/models/user_spec.rb
    # e.g. app/controllers/users_controller.rb -> spec/controllers/users_controller_spec.rb

    parts = list(p.parts)
    try:
        app_index = parts.index("app")
    except ValueError:
        # If 'app' is not in the path, we can't determine the spec path reliably for standard Rails structure
        return None

    parts[app_index] = "spec"

    # Insert _spec before the .rb extension
    spec_filename = f"{p.stem}_spec.rb"
    parts[-1] = spec_filename

    spec_path = Path(*parts)

    return str(spec_path) if spec_path.exists() else None


def is_valid_ruby_file(file_path: str) -> bool:
    """
    Checks if the given path is a valid Ruby file.

    Args:
        file_path: The path to the file.

    Returns:
        True if the file is a valid Ruby file, False otherwise.
    """
    return os.path.isfile(file_path) and file_path.endswith(".rb")
