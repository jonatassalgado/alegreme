import json
import random
import requests


class ProxyService:
    url = "https://proxy.webshare.io/api/proxy/list/"
    querystring = {"page": "1"}
    headers = {"Authorization": "Token 73a3ebc67a2d6842002063bf58affc9dd3ebe04c"}
    proxy_list = []

    def get_proxy_list(self):
        proxy_response = requests.request(
            "GET", self.url, headers=self.headers, params=self.querystring)
        proxy_data = proxy_response.json()
        self.proxy_list = proxy_data['results']

    def shuffle_list(self):
        random.shuffle(self.proxy_list)

    def select_proxy(self):
        ip = self.proxy_list[0]["proxy_address"]
        port = self.proxy_list[0]["ports"]["http"]
        username = self.proxy_list[0]["username"]
        password = self.proxy_list[0]["password"]

        # print(f'Selected proxy {self.proxy_list[0]}')

        return {
            'ip': ip,
            'port': port,
            'username': username,
            'password': password
        }
