require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

GANACHE_RPC_URL = process.env.GANACHE_RPC_URL;
GANACHE_CHAINID = parseInt(process.env.GANACHE_CHAINID);
GANACHE_ADDRESS = process.env.GANACHE_ADDRESS.split(",");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        ganache: {
            url: GANACHE_RPC_URL,
            accounts: GANACHE_ADDRESS,
            chainId: GANACHE_CHAINID,
        },
        localhost: {
            url: "http://127.0.0.1:8545",
            chainId: 31337,
        },
    },
    solidity: "0.8.17",
};
