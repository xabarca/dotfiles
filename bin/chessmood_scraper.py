import requests
from lxml import html
import subprocess

HOME_URL = "https://chessmood.com/?login"
LOGIN_URL = "https://chessmood.com/login"
URL = "https://chessmood.com/course/whitemood-openings"

USERNAME = "canadian@gmail.com"

def getStringCallBash(bashInstruction):
    processed = subprocess.check_output(bashInstruction)
    string = str(processed)
    string = string.replace("b'", "")
    string = string.replace("\\n'", "")
    return string

def main():
    session_requests = requests.session()

    # Get password for chessmood.com
    whoami = getStringCallBash(["whoami"])
    homedir = "/home/" + whoami
    PASSWORD = getStringCallBash([homedir + "/bin/pashage", "s", "chessmood"])

    # Get home page token
    result = session_requests.get(HOME_URL)
    tree = html.fromstring(result.text)
    authenticity_token = list(set(tree.xpath("//input[@name='_token']/@value")))[0]

    # Create payload
    payload = {
        "email": USERNAME,
        "password": PASSWORD,
        "_token": authenticity_token
    }

    # Perform login
    result = session_requests.post(LOGIN_URL, data = payload, headers = dict(referer = HOME_URL))

    # Scrape url
    result = session_requests.get(URL, headers = dict(referer = URL))

    #file = open("page.html", "w")
    #file.write(result.text)
    #file.close

    # Create Netscape cookies file
    file = open("cookies", "w")
    file.write("# Netscape HTTP Cookie File\r\n")
    for c in session_requests.cookies:
        file.write(c.domain + "\tFALSE\t/\tTRUE\t" + str(c.expires) + "\t" + c.name + "\t" + c.value + "\r\n")
    file.close

if __name__ == '__main__':
    main()

