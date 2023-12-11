#!/bin/bash
# Grab Twitter guest account tokens for use with Nitter. 

source .env

max_count=$1

function enable_airplane_mode {
  am broadcast -a net.dinglish.tasker.airplane -e enabled 1 &> /dev/null
}

function disable_airplane_mode {
  am broadcast -a net.dinglish.tasker.airplane -e enabled 0 &> /dev/null
}

function toggle_airplane_mode {
  enable_airplane_mode
  sleep 2
  disable_airplane_mode
}

function cleanup {
  disable_airplane_mode
  echo "Remember to re-enable wifi manually"
}
trap cleanup EXIT

# Disable wifi
read -p "Turn off wifi manually (enter to continue)" </dev/tty

count=0
echo Getting $max_count guest tokens >&2
while [ "$count" -lt "$max_count" ]; do
  guest_token=$(curl -s -m 10 -XPOST https://api.twitter.com/1.1/guest/activate.json -H 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAFXzAwAAAAAAMHCxpeSDG1gLNLghVe8d74hl6k4%3DRUMF4xAQLsbeBhTSRrCiQpJtxoGWeyHrDb5te2jpGskWDFW82F' | jq -r '.guest_token')

  flow_token=$(curl -s -m 10 -XPOST 'https://api.twitter.com/1.1/onboarding/task.json?flow_name=welcome&api_version=1&known_device_token=&sim_country_code=us' \
    -H 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAFXzAwAAAAAAMHCxpeSDG1gLNLghVe8d74hl6k4%3DRUMF4xAQLsbeBhTSRrCiQpJtxoGWeyHrDb5te2jpGskWDFW82F' \
    -H 'Content-Type: application/json' \
    -H 'User-Agent: TwitterAndroid/9.95.0-release.0 (29950000-r-0) ONEPLUS+A3010/9 (OnePlus;ONEPLUS+A3010;OnePlus;OnePlus3;0;;1;2016)' \
    -H 'X-Twitter-API-Version: 5' \
    -H 'X-Twitter-Client: TwitterAndroid' \
    -H 'X-Twitter-Client-Version: 9.95.0-release.0' \
    -H 'OS-Version: 28' \
    -H 'System-User-Agent: Dalvik/2.1.0 (Linux; U; Android 9; ONEPLUS A3010 Build/PKQ1.181203.001)' \
    -H 'X-Twitter-Active-User: yes' \
    -H "X-Guest-Token: ${guest_token}" \
    -d '{"flow_token":null,"input_flow_data":{"country_code":null,"flow_context":{"start_location":{"location":"splash_screen"}},"requested_variant":null,"target_user_id":0},"subtask_versions":{"generic_urt":3,"standard":1,"open_home_timeline":1,"app_locale_update":1,"enter_date":1,"email_verification":3,"enter_password":5,"enter_text":5,"one_tap":2,"cta":7,"single_sign_on":1,"fetch_persisted_data":1,"enter_username":3,"web_modal":2,"fetch_temporary_password":1,"menu_dialog":1,"sign_up_review":5,"interest_picker":4,"user_recommendations_urt":3,"in_app_notification":1,"sign_up":2,"typeahead_search":1,"user_recommendations_list":4,"cta_inline":1,"contacts_live_sync_permission_prompt":3,"choice_selection":5,"js_instrumentation":1,"alert_dialog_suppress_client_events":1,"privacy_options":1,"topics_selector":1,"wait_spinner":3,"tweet_selection_urt":1,"end_flow":1,"settings_list":7,"open_external_link":1,"phone_verification":5,"security_key":3,"select_banner":2,"upload_media":1,"web":2,"alert_dialog":1,"open_account":2,"action_list":2,"enter_phone":2,"open_link":1,"show_code":1,"update_users":1,"check_logged_in_account":1,"enter_email":2,"select_avatar":4,"location_permission_prompt":2,"notifications_permission_prompt":4}}' | jq -r .flow_token)

  token=$(curl -s -m 10 -XPOST 'https://api.twitter.com/1.1/onboarding/task.json' \
    -H 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAFXzAwAAAAAAMHCxpeSDG1gLNLghVe8d74hl6k4%3DRUMF4xAQLsbeBhTSRrCiQpJtxoGWeyHrDb5te2jpGskWDFW82F' \
    -H 'Content-Type: application/json' \
    -H 'User-Agent: TwitterAndroid/9.95.0-release.0 (29950000-r-0) ONEPLUS+A3010/9 (OnePlus;ONEPLUS+A3010;OnePlus;OnePlus3;0;;1;2016)' \
    -H 'X-Twitter-API-Version 5' \
    -H 'X-Twitter-Client: TwitterAndroid' \
    -H 'X-Twitter-Client-Version: 9.95.0-release.0' \
    -H 'OS-Version: 28' \
    -H 'System-User-Agent: Dalvik/2.1.0 (Linux; U; Android 9; ONEPLUS A3010 Build/PKQ1.181203.001)' \
    -H 'X-Twitter-Active-User: yes' \
    -H "X-Guest-Token: ${guest_token}" \
    -d "{\"flow_token\":\"${flow_token}\",\"subtask_inputs\":[{\"open_link\":{\"link\":\"next_link\"},\"subtask_id\":\"NextTaskOpenLink\"}],\"subtask_versions\":{\"generic_urt\":3,\"standard\":1,\"open_home_timeline\":1,\"app_locale_update\":1,\"enter_date\":1,\"email_verification\":3,\"enter_password\":5,\"enter_text\":5,\"one_tap\":2,\"cta\":7,\"single_sign_on\":1,\"fetch_persisted_data\":1,\"enter_username\":3,\"web_modal\":2,\"fetch_temporary_password\":1,\"menu_dialog\":1,\"sign_up_review\":5,\"interest_picker\":4,\"user_recommendations_urt\":3,\"in_app_notification\":1,\"sign_up\":2,\"typeahead_search\":1,\"user_recommendations_list\":4,\"cta_inline\":1,\"contacts_live_sync_permission_prompt\":3,\"choice_selection\":5,\"js_instrumentation\":1,\"alert_dialog_suppress_client_events\":1,\"privacy_options\":1,\"topics_selector\":1,\"wait_spinner\":3,\"tweet_selection_urt\":1,\"end_flow\":1,\"settings_list\":7,\"open_external_link\":1,\"phone_verification\":5,\"security_key\":3,\"select_banner\":2,\"upload_media\":1,\"web\":2,\"alert_dialog\":1,\"open_account\":2,\"action_list\":2,\"enter_phone\":2,\"open_link\":1,\"show_code\":1,\"update_users\":1,\"check_logged_in_account\":1,\"enter_email\":2,\"select_avatar\":4,\"location_permission_prompt\":2,\"notifications_permission_prompt\":4}}" | jq -rc '.subtasks[0]|if(.open_account) then .open_account else empty end')

  # Token is empty, toggle airplane mode to get a new ip
  if [ -z "$token" ]; then
    toggle_airplane_mode
    until curl -s -m 10 --head 1.1.1.1 &> /dev/null; do
      disable_airplane_mode # Try disabling airplane mode in case it's stuck
      sleep 2;
    done
    continue
  fi

  echo $token | curl -s -m 10 -X POST $UPLOAD_URL/append -H "x-auth: $NITTER_GUESTS_AUTH" --data @-
  echo $token
  ((count++))
done
