1. Choose a random proxy-nonce
2. Learn proxy address with new-proxy.fif
3. Set the address in func/config.fc and recompile pool contract
4. Run new-pool.fif (it will save pool address to data/pool.addr)
5. Rerun new-proxy.fif to recreate init message
6. Deploy proxy and pool with data/proxy-create.boc and data/pool-create.boc queries
7. Check that the proxy is initialized correctly by running get_pool_addr get-method
