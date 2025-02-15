import {HardhatUserConfig, task} from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "@matterlabs/hardhat-zksync-toolbox";

import "@typechain/hardhat";

import "hardhat-preprocessor";
import * as fs from "fs";
import {RichWallets} from "./utils/addresses";
import {setup} from "./utils/config";

setup();

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

// const DevNetPrivateKeys = [
//   "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
//   "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
//   "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
// ]

task("autoMine", "Automatically mines blocks", async (_, { ethers }) => {
  const mineInterval = 5000;

  setInterval(async () => {
    await ethers.provider.send("evm_mine", []);
    console.log(`Mined a new block at ${new Date().toISOString()}`);
  }, mineInterval);
});

const DevNetPrivateKeys = RichWallets.map((wallet) => wallet.privateKey)

const config: HardhatUserConfig = {
  mocha: {
    timeout: 120000,
  },

  // zksolc: process.env.IS_ZKSYNC ? {
  //   version: "1.3.10",
  //   compilerSource: "binary",
  //   settings: {
  //     // optional. Ignored for compilerSource "docker". Can be used if compiler is located in a specific folder
  //     compilerPath: process.env.ZK_SOLC_COMPILER_PATH,
  //     libraries: {}, // optional. References to non-inlinable libraries
  //     isSystem: false, // optional.  Enables Yul instructions available only for zkSync system src and libraries
  //     forceEvmla: false, // optional. Falls back to EVM legacy assembly if there is a bug with Yul
  //     optimizer: {
  //       enabled: true, // optional. True by default
  //       mode: '3' // optional. 3 by default, z to optimize bytecode size
  //     }
  //   }
  // } : undefined,

  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          // evmVersion: "cancun",
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ],
  },

  defaultNetwork: process.env.DEFAULT_ENV || "dev",
  networks: {
    // hardhat: {
    // },

    hardhat: {
      mining: {
        auto: true, // 启用自动挖矿
        interval: 500 // 设置挖矿间隔时间（以毫秒为单位）
      }
    },
    dev: {
      chainId: Number(process.env.DEVNET_CHAIN_ID),
      url: process.env.DEVNET_RPC_URL, // The testnet RPC URL of zkSync Era network.
      accounts: [process.env.DEVNET_PRIVATE_KEY || DevNetPrivateKeys[0], ...DevNetPrivateKeys.slice(1)],
      ethNetwork: process.env.DEVNET_ETH_NETWORK,
      zksync: process.env.IS_ZKSYNC?.toLowerCase() == "true",
      allowUnlimitedContractSize: true
    },
    test: {
      chainId: Number(process.env.TESTNET_CHAIN_ID),
      url: process.env.TESTNET_RPC_URL,
      accounts: [process.env.TESTNET_PRIVATE_KEY || process.env.PRIVATE_KEY],
      ethNetwork: process.env.TESTNET_ETH_NETWORK,
      zksync: process.env.IS_ZKSYNC?.toLowerCase() == "true",
      verifyURL: process.env.TESTNET_VERIFY_URL
    },
    main: {
      chainId: Number(process.env.MAINNET_CHAIN_ID),
      url: process.env.MAINNET_RPC_URL,
      accounts: [process.env.MAINNET_PRIVATE_KEY || process.env.PRIVATE_KEY],
      ethNetwork: process.env.MAINNET_ETH_NETWORK,
      zksync: process.env.IS_ZKSYNC?.toLowerCase() == "true",
      verifyURL: process.env.MAINNET_VERIFY_URL
    }
  },
  etherscan: {
    apiKey: {
      sepolia: "4B2ZD8S3NB62P1JMJ5GC856U7SGKRC3G69",
      test: "4B2ZD8S3NB62P1JMJ5GC856U7SGKRC3G69",
    },
    customChains: [
      {
        network: "test",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io"
        }
      }
    ]
  },

  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
  },
};

export default config;
