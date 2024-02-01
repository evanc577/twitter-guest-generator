#!/usr/bin/env python3

import requests
import base64

def main():
    username = 'XXXXXXXXXXXX'
    password = 'XXXXXXXXXXXX'
    TW_CONSUMER_KEY = '3nVuSoBZnx6U4vzUxf5w'
    TW_CONSUMER_SECRET = 'Bcs59EFbbsdF6Sl9Ng71smgStWEGwXXKSjYvPVt7qys'
    TW_ANDROID_BASIC_TOKEN = 'Basic {token}'.format(token=base64.b64encode(
        (TW_CONSUMER_KEY + ":" + TW_CONSUMER_SECRET).encode()
    ).decode())

    authentication = None
    bearer_token_resp = requests.post("https://api.twitter.com/oauth2/token",
        headers={
          'Authorization': TW_ANDROID_BASIC_TOKEN,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        data='grant_type=client_credentials'
    )
    assert bearer_token_resp.ok
    bearer_token_json = bearer_token_resp.json()
    bearer_token = ' '.join(str(x) for x in bearer_token_json.values())
    # print(bearer_token)

    # The bearer token is immutable
    # Bearer AAAAAAAAAAAAAAAAAAAAAFXzAwAAAAAAMHCxpeSDG1gLNLghVe8d74hl6k4%3DRUMF4xAQLsbeBhTSRrCiQpJtxoGWeyHrDb5te2jpGskWDFW82F
    guest_token = requests.post("https://api.twitter.com/1.1/guest/activate.json", headers={
        'Authorization': bearer_token,
    }).json()['guest_token']
    # print(guest_token)

    twitter_header = {
        'Authorization': bearer_token,
        "Content-Type": "application/json",
        "User-Agent":
            "TwitterAndroid/9.95.0-release.0 (29950000-r-0) ONEPLUS+A3010/9 (OnePlus;ONEPLUS+A3010;OnePlus;OnePlus3;0;;1;2016)",
        "X-Twitter-API-Version": '5',
        "X-Twitter-Client": "TwitterAndroid",
        "X-Twitter-Client-Version": "9.95.0-release.0",
        "OS-Version": "28",
        "System-User-Agent":
            "Dalvik/2.1.0 (Linux; U; Android 9; ONEPLUS A3010 Build/PKQ1.181203.001)",
        "X-Twitter-Active-User": "yes",
        "X-Guest-Token": guest_token,
    }

    session = requests.Session()

    task1 = session.post('https://api.twitter.com/1.1/onboarding/task.json',
        params={
            'flow_name': 'login',
            'api_version': '1',
            'known_device_token': '',
            'sim_country_code': 'us'
        },
        json={
            "flow_token": None,
            "input_flow_data": {
                "country_code": None,
                "flow_context": {
                    "referrer_context": {
                        "referral_details": "utm_source=google-play&utm_medium=organic",
                        "referrer_url": ""
                    },
                    "start_location": {
                        "location": "deeplink"
                    }
                },
                "requested_variant": None,
                "target_user_id": 0
            }
        },
        headers=twitter_header
    )
    task1.raise_for_status()

    session.headers['att'] = task1.headers.get('att')
    task2 = session.post('https://api.twitter.com/1.1/onboarding/task.json', 
        json={
            "flow_token": task1.json().get('flow_token'),
            "subtask_inputs": [{
                    "enter_text": {
                        "suggestion_id": None,
                        "text": username,
                        "link": "next_link"
                    },
                    "subtask_id": "LoginEnterUserIdentifier"
                }
            ]
        },
        headers=twitter_header
    )
    task2.raise_for_status()

    task3 = session.post('https://api.twitter.com/1.1/onboarding/task.json', 
        json={
            "flow_token": task2.json().get('flow_token'),
            "subtask_inputs": [{
                    "enter_password": {
                        "password": password,
                        "link": "next_link"
                    },
                    "subtask_id": "LoginEnterPassword"
                }
            ],
        },
        headers=twitter_header
    )
    task3.raise_for_status()

    task4 = session.post('https://api.twitter.com/1.1/onboarding/task.json', 
        json={
            "flow_token": task3.json().get('flow_token'),
            "subtask_inputs": [{
                    "check_logged_in_account": {
                        "link": "AccountDuplicationCheck_false"
                    },
                    "subtask_id": "AccountDuplicationCheck"
                }
            ]
        },
        headers=twitter_header
    )
    task4.raise_for_status()
    task4_json = task4.json()

    for t4_subtask in task4_json.get('subtasks', []):
        if 'open_account' in t4_subtask:
            authentication = t4_subtask['open_account']
            break
        elif 'enter_text' in t4_subtask:
            response_text = t4_subtask['enter_text']['hint_text']
            code = input(f'Requesting {response_text}: ')
            task5 = session.post('https://api.twitter.com/1.1/onboarding/task.json', json={
                "flow_token": task4_json.get('flow_token'),
                "subtask_inputs": [{
                    "enter_text": {
                        "suggestion_id": None,
                        "text": code,
                        "link": "next_link"
                    },
                    "subtask_id": "LoginAcid"
                }]
            }, headers=twitter_header)
            assert task5.ok
            task5_json = task5.json()
            # print(task5)
            for t5_subtask in task5_json.get('subtasks', []):
                # print(t5_subtask)
                if 'open_account' in t5_subtask:
                    authentication = t5_subtask['open_account']

    print(authentication)

if __name__ == "__main__":
    main()
