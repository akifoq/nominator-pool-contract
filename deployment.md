1. Choose a random proxy-nonce
2. Run new-proxy.fif to save proxy address
3. Run new-pool.fif (it will save pool address to data/pool.addr)
4. Rerun new-proxy.fif to recreate init message
5. Deploy proxy and pool with data/proxy-create.boc and data/pool-create.boc queries
6. Check that the proxy is initialized correctly by running get_pool_addr get-method
