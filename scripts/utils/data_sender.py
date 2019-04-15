from requests_futures.sessions import FuturesSession

class DataSender:
    def __init__(self, username, key):
        self.session = FuturesSession()
        self.headers = {
            'User-Agent': 'mica-vibe/0.0.1',
            'Content-Type': 'application/json',
            'X-AIO-Key': key
        }
        self.base_url = "https://io.adafruit.com/api/v2/{}/feeds".format(username)

    def send_data(self, feed, value):
        suffix = "/{}/data".format(feed)
        full_url = self.base_url + suffix
        print("POST {}".format(full_url))
        self.session.post(full_url, data={"value": value}, hooks={
            'response', self.response_hook
        })

    def response_hook(self, resp, *args, **kwargs):
        # parse the json storing the result on the response object
        print("GOT {} RESPONSE JSON: {}".format(resp.status_code, resp.json()))
