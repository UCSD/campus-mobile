from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.user_credential import UserCredential
import os
import sys
import json

# site_url = str(sys.argv[1]).strip() #"https://ucsdcloud.sharepoint.com/sites/WorkplaceTechnologyServices-CampusMobileBuilds"
site_url = "https://ucsdcloud.sharepoint.com/sites/WorkplaceTechnologyServices-CampusMobileBuilds/"
credentials = json.loads(str(sys.argv[2]))
user = credentials["username"]
password = credentials["password"]
fileOptions = json.loads(str(sys.argv[3]))
fileName = fileOptions["fileName"].strip() #same as local_path
# folder = fileOptions["folder"] #/sites/WorkplaceTechnologyServices-CampusMobileBuilds/Shared Documents/Campus Mobile Builds/Folder here
folder = "/sites/WorkplaceTechnologyServices-CampusMobileBuilds/Shared Documents/Campus Mobile Builds/Pull Request Builds/"


user_credentials = UserCredential(user, password)
remote_path = folder + fileName

# local_path = "7.32.0-TEST-UPLOAD.apk"
# remote_path = "/sites/WorkplaceTechnologyServices-CampusMobileBuilds/Shared Documents/Campus Mobile Builds/test.txt"
#
# password = os.getenv('WORK_PASSWORD')
# if not password:
#     raise RuntimeError("Environment variable 'WORK_PASSWORD' not set.")

# user_credentials = UserCredential(
#     'anw075@ucsd.edu',
#     password
#     )

ctx = ClientContext(site_url).with_credentials(user_credentials)
web = ctx.web
ctx.load(web)
ctx.execute_query()
print(f"Web title: {web.properties['Title']}")

with open(fileName, 'rb') as test_file:
    file_content = test_file.read()

dir, name = os.path.split(remote_path)
print(f"trying to upload{fileName} to {remote_path}")
try:
    file = ctx.web.get_folder_by_server_relative_url(dir).upload_file(name, file_content).execute_query()
    print(f'uploaded file {fileName} to {remote_path}')
    sys.exit(0)
except Exception as e:
    print(f"Error in python script: {e}")
    sys.exit(1)
