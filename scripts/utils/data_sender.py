from requests_futures.sessions import FuturesSession
import json

class DataSender:
    def __init__(self, username, key, debug=False):
        self.session = FuturesSession()
        self.headers = {
            'User-Agent': 'mica-vibe/0.0.1',
            'Content-Type': 'application/json',
            'X-AIO-Key': key
        }
        self.debug = debug
        self.base_url = "https://io.adafruit.com/api/v2/{}/feeds".format(username)
        self.session.hooks['response'] = self.response_hook

    def send_data(self, feed, value):
        suffix = "/{}/data".format(feed)
        full_url = self.base_url + suffix
        if self.debug:
            print("[DataSender send_data] POST {}".format(full_url))
        return self.session.post(full_url, headers=self.headers, data=json.dumps({"value": value}))

    def response_hook(self, resp, *args, **kwargs):
        if self.debug:
            print("[DataSender send_data] got response status: {}".format(resp.status_code))

if __name__=="__main__":
    import time

    ds = DataSender('mica_ia', '3a9f2b3bac204522a133fc4494c983ad', debug=True)
    req = ds.send_data('mood', 'test')
