import subprocess
import os
import sys
import re
import time
import json
import select
import platform

# Global definitions
project_path = os.path.expanduser('~/development/campus-mobile')  # Default installation folder for Campus Mobile
avd_name = ""  # Global variable to store the name of the Android Virtual Device (AVD)


##############################################################################################################
# Main
##############################################################################################################

def main():
	print(r"""
   ____                                  __  __       _     _ _        ___           _        _ _           
  / ___|__ _ _ __ ___  _ __  _   _ ___  |  \/  | ___ | |__ (_) | ___  |_ _|_ __  ___| |_ __ _| | | ___ _ __ 
 | |   / _` | '_ ` _ \| '_ \| | | / __| | |\/| |/ _ \| '_ \| | |/ _ \  | || '_ \/ __| __/ _` | | |/ _ \ '__|
 | |__| (_| | | | | | | |_) | |_| \__ \ | |  | | (_) | |_) | | |  __/  | || | | \__ \ || (_| | | |  __/ |   
  \____\__,_|_| |_| |_| .__/ \__,_|___/ |_|  |_|\___/|_.__/|_|_|\___| |___|_| |_|___/\__\__,_|_|_|\___|_|   
                      |_|                                                                                   
""")
	print("Welcome to the Campus Mobile (MacOS) Installer.")
	print("\nThe installer will perform the following actions:")
	print("  1. Install Xcode Command Line Tools")
	print("  2. Install Homebrew")
	print("  3. Install Git")
	print("  4. Install Java")
	print("  5. Install VS Code")
	print("  6. Install Flutter")
	print("  7. Install Android Tools")
	print("  8. Create & Launch Android Emulator")
	print("  9. Install Campus Mobile")
	print(" 10. Configure Campus Mobile")
	print(" 11. Build & Run Campus Mobile")

	proceed = input("Press 'Y' to continue with the installation, any other key to exit: ").strip().upper()
	if proceed == "Y":
		print("\nStarting installation... Please be patient as this process may take up to 15 minutes.\n")
		backup_zshrc() # 0/11
		install_xcode_command_line_tools() # 1/11
		install_homebrew() # 2/11
		install_git() # 3/11
		install_java() # 4/11
		install_vs_code() # 5/11
		install_flutter() # 6/11
		install_android_tools() # 7/11
		create_android_emulator() # 8/11
		install_campus_mobile() # 9/11
		configure_campus_mobile() # 10/11
		run_campus_mobile() # 11/11
	else:
		print("Installation canceled.")
		sys.exit(0)


##############################################################################################################
# 1/11  Install Xcode Command Line Tools
##############################################################################################################
def install_xcode_command_line_tools():
    # Check if Xcode Command Line Tools need to be installed
	if not pkg_installed('com.apple.pkg.CLTools_Executables'):
		prompt_until_xcode_tools_installed()
	print(" 1/11  Xcode Command Line Tools installation complete.")

def prompt_until_xcode_tools_installed():
	print("\n  *** USER ACTION REQUIRED ***")
	print("  1. Locate the installer pop-up window that appears.")
	print("  2. Click 'Install' to begin the installation of Xcode Command Line Tools.")

	# Start the installation process in the background
	subprocess.Popen("xcode-select --install", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)
	try:
		input("\nAfter completing the installation, press any key to continue (or Control-C to exit).")
	except KeyboardInterrupt:
		print("Installation interrupted by user. Exiting...")
		sys.exit(0)

	install_xcode_command_line_tools()


##############################################################################################################
# 2/11  Install Homebrew
##############################################################################################################
def install_homebrew():
	if is_installed('brew'):
		subprocess.run(['brew', 'upgrade'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
		print(" 2/11  Homebrew upgrade complete.")
	else:
		subprocess.run('echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)
		print(" 2/11  Homebrew installation complete.")


##############################################################################################################
# 3/11  Install Git
##############################################################################################################
def install_git():
	if not is_installed('git'):
		subprocess.run(['brew', 'install', 'git'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
	
	user_name = subprocess.run(['git', 'config', 'user.name'], capture_output=True, text=True).stdout.strip()
	if not user_name:
		user_name = input("Enter your Git user name: ")
		subprocess.run(['git', 'config', '--global', 'user.name', user_name])
	
	user_email = subprocess.run(['git', 'config', 'user.email'], capture_output=True, text=True).stdout.strip()
	if not user_email:
		user_email = input("Enter your Git user email: ")
		subprocess.run(['git', 'config', '--global', 'user.email', user_email])
	
	print(" 3/11  Git installation complete.")


##############################################################################################################
# 4/11  Install Java
##############################################################################################################
def install_java():
	if not check_openjdk_version():
		subprocess.run(['brew', 'install', 'openjdk@17'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['brew', 'link', 'openjdk@17', '--force', '--overwrite'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

		# Get the path to the installed Java version
		java_home = subprocess.check_output(['/usr/libexec/java_home', '-v', '17']).decode().strip()

		# Add JAVA_HOME and its bin directory to the PATH
		add_path_to_zshrc([f'{java_home}', f'{java_home}/bin'])
	print(" 4/11  Java installation complete.")

def check_openjdk_version(min_version=17):
	try:
		result = subprocess.run(['java', '-version'], stderr=subprocess.PIPE, text=True)
		version_output = result.stderr
		if 'openjdk' in version_output.lower():
			version_match = re.search(r'\"(\d+)\.\d+\.\d+\"', version_output)
			if version_match:
				major_version = int(version_match.group(1))
				return major_version >= min_version
		return False
	except FileNotFoundError:
		return False


##############################################################################################################
# 5/11  Install VS Code
##############################################################################################################
def install_vs_code():
	if not is_installed('code'):
		subprocess.run(['brew', 'install', '--cask', 'visual-studio-code'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
	# Install extensions
	install_vs_code_extensions()
	print(" 5/11  VS Code installation complete.")

# Function to install VS Code extensions
def install_vs_code_extensions():
	# List all installed extensions
	installed_extensions = subprocess.run(['code', '--list-extensions'], capture_output=True, text=True).stdout.split()
	# Define required extensions
	required_extensions = ['dart-code.dart-code', 'dart-code.flutter']

	# Install required extensions if they are not already installed
	for extension in required_extensions:
		if extension not in installed_extensions:
			subprocess.run(['code', '--install-extension', extension], check=True)


##############################################################################################################
# 6/11  Install Flutter
##############################################################################################################
def install_flutter():
	# Try to determine the Flutter binary path dynamically
	flutter_exec_path = subprocess.run(['which', 'flutter'], capture_output=True, text=True).stdout.strip()
	
	if flutter_exec_path:
		flutter_bin_path = os.path.dirname(flutter_exec_path)
		check_and_switch_flutter_version(flutter_bin_path)
		add_flutter_to_path(os.path.dirname(flutter_bin_path))
	else:
		# Install Flutter in the designated directory
		flutter_dir = os.path.expanduser('~/development/flutter')
		if not os.path.exists(flutter_dir):
			os.makedirs(flutter_dir, exist_ok=True)
			subprocess.run(['git', 'clone', 'https://github.com/flutter/flutter.git', '-b', '3.7.3', flutter_dir], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		add_flutter_to_path(flutter_dir)
	print(" 6/11  Flutter installation complete.")

def add_flutter_to_path(flutter_dir):
	flutter_bin_path = os.path.join(flutter_dir, 'bin')
	dart_sdk_path = os.path.join(flutter_bin_path, 'cache', 'dart-sdk')
	add_path_to_zshrc([flutter_bin_path, dart_sdk_path])

def check_and_switch_flutter_version(flutter_bin_path):
	# Check the current Flutter version
	flutter_version_output = subprocess.run(['flutter', '--version'], capture_output=True, text=True).stdout
	if "Flutter 3.7.3" not in flutter_version_output:
		print("Switching to Flutter version 3.7.3...")
		os.chdir(os.path.dirname(flutter_bin_path))
		subprocess.run(['git', 'fetch'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['git', 'checkout', '3.7.3'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)


##############################################################################################################
# 7/11  Install Android tools
##############################################################################################################
def install_android_tools():
	try:
		# Install Android SDK command-line tools and platform tools
		subprocess.run(['brew', 'install', '--cask', 'android-commandlinetools'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['brew', 'install', '--cask', 'android-platform-tools'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

		# Update sdkmanager and accept licenses
		subprocess.run(['sdkmanager', '--update'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run('yes | sdkmanager --licenses', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)

		# Install specific SDK platform and build tools
		subprocess.run(['sdkmanager', '--install', 'platform-tools'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['sdkmanager', '--install', 'platforms;android-34'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['sdkmanager', '--install', 'build-tools;30.0.3'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

		# Install system image based on architecture
		system_image = get_android_system_image()
		subprocess.run(['sdkmanager', '--install', system_image], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

		# Install the Android emulator
		subprocess.run(['sdkmanager', '--install', 'emulator'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

		# Configure Android SDK environment variables and add to PATH
		android_home = subprocess.run(['brew', '--prefix'], capture_output=True, text=True).stdout.strip()
		android_home += '/share/android-commandlinetools'
		android_cmdline_tools = os.path.join(android_home, 'cmdline-tools', 'latest', 'bin')
		platform_tools = os.path.join(android_home, 'platform-tools')
		platforms = os.path.join(android_home, 'platforms', 'android-34')
		build_tools = os.path.join(android_home, 'build-tools', '30.0.3')
		android_emulator = os.path.join(android_home, 'emulator')
		add_path_to_zshrc([android_cmdline_tools, platform_tools, android_emulator, platforms, build_tools])
		add_export_to_zshrc("ANDROID_SDK_ROOT", android_home)

		print(" 7/11  Android Tools installation complete.")
	except subprocess.CalledProcessError as e:
		print(f"Failed to install Android tools: {e}")
		sys.exit(1)


##############################################################################################################
# 8/11  Create & Launch Android Emulator
##############################################################################################################
def create_android_emulator():
	global avd_name
	system_image = get_android_system_image()
	avd_name = get_available_avd_name("Pixel_6")
	
	subprocess.run(['avdmanager', 'create', 'avd', '-n', avd_name, '-k', system_image, '--device', 'pixel_6'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
	
	# Start the emulator in the background
	emulator_process = subprocess.Popen(['emulator', '-avd', avd_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)

	# Check if the emulator is ready
	def emulator_is_ready():
		start_time = time.time()
		while True:
			if (time.time() - start_time) > 120:
				return False

			if select.select([emulator_process.stdout], [], [], 0.1)[0]:
				line = emulator_process.stdout.readline().lower()
				if "boot completed" in line or "ready" in line or "successfully loaded" in line:
					return True
			else:
				time.sleep(0.1)

	if not emulator_is_ready():
		print("Emulator failed to start within the timeout period. Please try again.")
		sys.exit(1)
	
	print(" 8/11  Android Emulator creation complete.")

def get_available_avd_name(base_name):
	counter = 1
	avd_name = base_name
	while avd_exists(avd_name):
		avd_name = f"{base_name}_{counter}"
		counter += 1
	return avd_name

def avd_exists(name):
	# Check if an AVD with the given name already exists
	result = subprocess.run(['avdmanager', 'list', 'avd'], capture_output=True, text=True)
	return name in result.stdout


##############################################################################################################
# 9/11  Install Campus Mobile
##############################################################################################################
def install_campus_mobile():
	github_username = get_github_username()
	origin_url = f'https://github.com/{github_username}/campus-mobile.git'
	upstream_url = 'https://github.com/UCSD/campus-mobile.git'

	if os.path.exists(project_path):
		# Campus Mobile repository already exists, update it
		os.chdir(project_path)
		subprocess.run(['git', 'stash'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		configure_origin(origin_url, upstream_url)
		set_git_remote('upstream', upstream_url)
		subprocess.run(['git', 'fetch', 'upstream'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['git', 'checkout', 'experimental'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		subprocess.run(['git', 'merge', 'upstream/experimental'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
	else:
		# Campus Mobile repository does not exist, clone it
		os.makedirs(os.path.dirname(project_path), exist_ok=True)
		subprocess.run(['git', 'clone', upstream_url, project_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		os.chdir(project_path)
		configure_origin(origin_url, upstream_url)
		set_git_remote('upstream', upstream_url)
		subprocess.run(['git', 'fetch', 'upstream'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

	print(" 9/11  Campus Mobile installation complete.")

def set_git_remote(remote_name, url):
	# Set or update a git remote
	result = subprocess.run(['git', 'remote', 'get-url', remote_name], capture_output=True, text=True)
	if result.returncode == 0:
		# Remote exists, set the new URL
		subprocess.run(['git', 'remote', 'set-url', remote_name, url], check=True)
	else:
		# Remote does not exist, add it
		subprocess.run(['git', 'remote', 'add', remote_name, url], check=True)

def configure_origin(origin_url, upstream_url):
	# Check the current URL of the origin remote.  Correct it if set to upstream URL.
	result = subprocess.run(['git', 'remote', 'get-url', 'origin'], capture_output=True, text=True)
	if result.returncode != 0:
		# No origin set, add it
		subprocess.run(['git', 'remote', 'add', 'origin', origin_url], check=True)
	else:
		origin_url_lower = result.stdout.strip().lower()
		upstream_url_lower = upstream_url.lower()

		if origin_url_lower == upstream_url_lower:
			# If the current origin URL is the upstream URL, change it to the origin_url
			subprocess.run(['git', 'remote', 'set-url', 'origin', origin_url], check=True)


##############################################################################################################
# 10/11  Configure Campus Mobile
##############################################################################################################
def configure_campus_mobile():
	downloads_path = os.path.expanduser('~/Downloads')
	installer_path = os.path.join(downloads_path, 'campus-mobile-installer')
	ios_path = os.path.join(project_path, 'ios', 'Runner')
	android_path = os.path.join(project_path, 'android', 'app')
	zip_files = ['campus-mobile-7.27-qa.env.zip', 'campus-mobile-push-qa.zip']

	expected_files = {
		'campus-mobile-7.27-qa.env.zip': os.path.join(installer_path, '.env'),
		'campus-mobile-push-qa.zip': [
			os.path.join(installer_path, 'ios', 'Runner', 'GoogleService-Info.plist'),
			os.path.join(installer_path, 'android', 'app', 'google-services.json')
		]
	}

	all_files_present = False  # Initialize the variable to control the loop

	while not all_files_present:
		try:
			if verify_and_extract(downloads_path, zip_files, installer_path):
				if check_files_present(expected_files):
					move_config_files(installer_path, project_path, ios_path, android_path)
					write_vscode_tasks(project_path)
					set_flutter_device_id(project_path)
					all_files_present = True
			else:
				print("\nError: Not all required files are in the ~/Downloads folder. Please check and try again.")
		
		except KeyboardInterrupt:
			print("Installation interrupted by user. Exiting...")
			sys.exit(0)
		except subprocess.CalledProcessError:
			pass
		except Exception as e:
			pass

		# Prompting user if initial file check fails
		if not all_files_present:
			print("\n  *** USER ACTION REQUIRED ***")
			print("  1. Navigate to LastPass -> All Items -> Search for 'Shared-Campus Mobile Config' -> View")
			print("  2. Save the files 'campus-mobile-7.27-qa.env.zip' and 'campus-mobile-push-qa.zip' directly to your '~/Downloads' folder.")
			try:
				input("\nPress any key to continue (or Control-C to exit).")
			except KeyboardInterrupt:
				print("Installation interrupted by user. Exiting...")
				sys.exit(0)

	clean_up_config_installer(installer_path)
	print("10/11  Campus Mobile configuration complete.")

def verify_and_extract(downloads_path, zip_files, installer_path):
	# Check if all zip files are present
	if all(os.path.exists(os.path.join(downloads_path, zip_file)) for zip_file in zip_files):
		os.makedirs(installer_path, exist_ok=True)  # Ensures installer directory is created here
		for zip_file in zip_files:
			command = ["unzip", "-o", os.path.join(downloads_path, zip_file), "-d", installer_path]
			subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		return True
	else:
		return False

def check_files_present(expected_files):
	all_files_present = True
	for zip_file, paths in expected_files.items():
		if isinstance(paths, list):
			for file_path in paths:
				if not os.path.exists(file_path):
					all_files_present = False
		else:
			if not os.path.exists(paths):
				all_files_present = False
	return all_files_present

def handle_missing_files(downloads_path, zip_files, expected_files, installer_path):
	verify_and_extract(downloads_path, zip_files, installer_path)
	if not check_files_present(expected_files):
		raise Exception("Repeated extraction attempts failed. Please check the source files.")

def clean_up_config_installer(installer_path):
	if 'campus-mobile-installer' in installer_path and os.path.exists(installer_path):
		subprocess.run(["rm", "-rf", installer_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

def move_config_files(installer_path, project_path, ios_path, android_path):
	try:
		subprocess.run(['mv', os.path.join(installer_path, '.env'), os.path.join(project_path, '.env')], check=True)
		subprocess.run(['mv', os.path.join(installer_path, 'ios', 'Runner', 'GoogleService-Info.plist'), os.path.join(ios_path, 'GoogleService-Info.plist')], check=True)
		subprocess.run(['mv', os.path.join(installer_path, 'android', 'app', 'google-services.json'), os.path.join(android_path, 'google-services.json')], check=True)
	except subprocess.CalledProcessError as e:
		print(f"Error moving files: {e}")
		raise

def write_vscode_tasks(project_path):
	vscode_path = os.path.join(project_path, '.vscode')
	os.makedirs(vscode_path, exist_ok=True)
	tasks_json_path = os.path.join(vscode_path, 'tasks.json')
	tasks = {
		"version": "2.0.0",
		"tasks": [
			{
				"label": "Fetch Dependencies",
				"type": "shell",
				"command": "flutter pub get",
				"group": {
					"kind": "build",
					"isDefault": True
				},
				"problemMatcher": [],
				"runOptions": {
					"runOn": "folderOpen"
				}
			},
			{
				"label": "Run on Emulator",
				"type": "shell",
				"command": "flutter run -d DEVICE_ID",
				"group": "test",
				"problemMatcher": [],
				"dependsOn": "Fetch Dependencies",
				"runOptions": {
					"runOn": "folderOpen"
				},
				"presentation": {
					"reveal": "always",
					"focus": True,
					"panel": "new"
				}
			}
		]
	}
	with open(tasks_json_path, 'w') as f:
		json.dump(tasks, f, indent=4)

def set_flutter_device_id(project_path):
	result = subprocess.run(['flutter', 'devices'], capture_output=True, text=True)
	devices = result.stdout
	# Look for a device that starts with 'emulator' and capture its ID
	match = re.search(r'emulator-(\d+)\s', devices)
	if match:
		device_id = 'emulator-' + match.group(1)
		update_task_json_device_id(device_id, project_path)

def update_task_json_device_id(device_id, project_path):
	tasks_json_path = os.path.join(project_path, '.vscode', 'tasks.json')
	with open(tasks_json_path, 'r+') as f:
		tasks = json.load(f)
		tasks['tasks'][1]['command'] = f"flutter run -d {device_id}"
		f.seek(0)
		f.truncate()
		json.dump(tasks, f, indent=4)


##############################################################################################################
# 11/11  Run Campus Mobile
##############################################################################################################
def run_campus_mobile():
	print("11/11  Campus Mobile build & run in progress...")

	# Open the project in VS Code
	subprocess.run(['code', project_path], check=True)

	# Summary of the operation with enhanced Git instructions
	print(f"""
*********************************************************************************
* Campus Mobile (MacOS) Installation Summary                                    *
*********************************************************************************
- Installation directory: ~/development/campus-mobile

- Git remote origin: {get_git_remote_origin()}

  If this is incorrect, set the correct remote using:
	git remote set-url origin https://github.com/<Your-GitHub-Username>/campus-mobile.git
*********************************************************************************
""")


##############################################################################################################
# 0/0  Utility functions
##############################################################################################################
def backup_zshrc():
	zshrc_path = os.path.expanduser('~/.zshrc')
	if os.path.exists(zshrc_path):
		timestamp = int(time.time())
		backup_path = f'{zshrc_path}.{timestamp}.bak'
		with open(zshrc_path, 'r') as original, open(backup_path, 'w') as backup:
			backup.write(original.read())

def ensure_zshrc_exists():
	zshrc_path = os.path.expanduser('~/.zshrc')
	if not os.path.exists(zshrc_path):
		with open(zshrc_path, 'w') as file:
			file.write('# Created by installer script\n')
	return zshrc_path

def add_path_to_zshrc(paths):
	zshrc_path = ensure_zshrc_exists()
	with open(zshrc_path, 'r+') as file:
		lines = file.readlines()
		export_found = any('export PATH' in line for line in lines)
		new_paths = [f'PATH={path}:$PATH' for path in paths if f'PATH={path}:$PATH' not in ''.join(lines)]

		if new_paths:
			if not export_found:
				lines.append('\n'.join(new_paths) + '\n')
				lines.append('export PATH\n')
			else:
				index = next(i for i, line in enumerate(lines) if 'export PATH' in line)
				lines[index:index] = [path + '\n' for path in new_paths]
			file.seek(0)
			file.truncate()
			file.writelines(lines)

def add_export_to_zshrc(var_name, value):
	zshrc_path = ensure_zshrc_exists()
	with open(zshrc_path, 'r+') as file:
		lines = file.readlines()
		export_string = f'export {var_name}="{value}"\n'
		
		# Check if the variable is already defined
		found = False
		for i, line in enumerate(lines):
			if line.startswith(f'export {var_name}='):
				lines[i] = export_string  # Update the existing line
				found = True
				break
		
		# If the variable was not found, append it
		if not found:
			lines.append(export_string)
		
		# Rewrite the file with updated or added export
		file.seek(0)
		file.truncate()
		file.writelines(lines)

def is_installed(command):
	return subprocess.run(['command', '-v', command], capture_output=True).returncode == 0

def pkg_installed(package_name):
	result = subprocess.run(['pkgutil', '--pkgs=' + package_name], capture_output=True, text=True)
	return bool(result.stdout.strip())

def get_android_system_image():
	architecture = platform.machine()
	if 'aarch64' in architecture or 'arm64' in architecture:
		return 'system-images;android-34;google_apis;arm64-v8a'
	elif 'x86_64' in architecture:
		return 'system-images;android-34;google_apis;x86_64'
	else:
		print("Unsupported system architecture: " + architecture)
		sys.exit(1)

def get_github_username():
	default_username = "Your_GitHub_Username"
	email_result = subprocess.run(['git', 'config', 'user.email'], capture_output=True, text=True)
	git_email = email_result.stdout.strip()
	if '@' in git_email:
		return git_email.split('@')[0]
	return default_username

def get_git_remote_origin():
	result = subprocess.run(['git', 'remote', 'get-url', 'origin'], capture_output=True, text=True)
	if result.returncode == 0:
		return result.stdout.strip()
	return "Not set"

# Initialize the script
if __name__ == "__main__":
	main()
