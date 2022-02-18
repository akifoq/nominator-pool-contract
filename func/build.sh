#!/bin/bash
func -SP stdlib+.fc config.fc msg_utils.fc ops.fc settings.fc storage.fc request_stake.fc stake_recover.fc stakers.fc text_utils.fc main.fc get_methods.fc -o auto/pool-code.fif
func -SP stdlib+.fc proxy.fc -o auto/proxy-code.fif
