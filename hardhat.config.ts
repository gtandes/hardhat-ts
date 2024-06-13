import { HardhatUserConfig, vars } from "hardhat/config";

import type { NetworkUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";

import "./tasks/accounts";

// Run 'npx hardhat vars setup' to see the list of variables that need to be set
const mnemonic: string = vars.get("MNEMONIC");
const alchemyApiKey: string = vars.get("ALCHEMY_API_KEY");

const chainIds = {
  ganache: 1337,
  hardhat: 31337,
  "eth-sepolia": 11155111,

  "calypso-testnet": 974399131,
  "europa-testnet": 1444673419,
  "nebula-testnet": 37084624,
  "titan-testnet": 1020352220,

  "calypso-mainnet": 1564830818,
  "europa-mainnet": 2046399126,
  "nebula-mainnet": 1482601649,
  "titan-mainnet": 1350216234,
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
  let jsonRpcUrl: string;

  switch (chain) {

    // mainnets
    case "calypso-mainnet":
      jsonRpcUrl = "https://mainnet.skalenodes.com/v1/honorable-steel-rasalhague";
      break;
    case "europa-mainnet":
      jsonRpcUrl = "https://mainnet.skalenodes.com/v1/elated-tan-skat";
      break;
    case "nebula-mainnet":
      jsonRpcUrl = "https://mainnet.skalenodes.com/fs/green-giddy-denebola";
      break;
    case "titan-mainnet":
      jsonRpcUrl = "https://mainnet.skalenodes.com/v1/parallel-stormy-spica";
      break;

    // testnets
    case "calypso-testnet":
      jsonRpcUrl = "https://testnet.skalenodes.com/v1/giant-half-dual-testnet";
      break;
    case "europa-testnet":
      jsonRpcUrl = "https://testnet.skalenodes.com/v1/juicy-low-small-testnet";
      break;
    case "nebula-testnet":
      jsonRpcUrl = "https://testnet.skalenodes.com/v1/lanky-ill-funny-testnet";
      break;
    case "titan-testnet":
      jsonRpcUrl = "https://testnet.skalenodes.com/v1/aware-fake-trim-testnet";
      break;

    default:
      jsonRpcUrl = "https://" + chain + ".g.alchemy.com/v2/" + alchemyApiKey;
  }

  return {
    accounts: {
      count: 10,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: 0,
  },

  etherscan: {
    apiKey: {
      sepolia: vars.get("ETHERSCAN_API_KEY", ""),
      mainnet: vars.get("ETHERSCAN_API_KEY", ""),
    },
  },

  gasReporter: {
    currency: "USD",
    enabled: process.env.REPORT_GAS ? true : false,
    excludeContracts: [],
    src: "./contracts",
  },

  networks: {
    hardhat: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.hardhat,
    },
    ganache: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.ganache,
      url: "http://localhost:8545",
    },
    "calypso-testnet": getChainConfig("calypso-testnet"),
    "europa-testnet": getChainConfig("europa-testnet"),
    "nebula-testnet": getChainConfig("nebula-testnet"),
    "titan-testnet": getChainConfig("titan-testnet"),
    sepolia: getChainConfig("eth-sepolia"),

    "calypso-mainnet": getChainConfig("calypso-mainnet"),
    "europa-mainnet": getChainConfig("europa-mainnet"),
    "nebula-mainnet": getChainConfig("nebula-mainnet"),
    "titan-mainnet": getChainConfig("titan-mainnet"),
  },

  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },

  solidity: {
    version: "0.8.24",
    settings: {
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      // Disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
};

export default config;
