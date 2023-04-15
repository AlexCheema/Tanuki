import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import verify from "../helper-functions";
import {
  networkConfig,
  developmentChains,
  QUORUM_PERCENTAGE,
  VOTING_PERIOD,
  VOTING_DELAY,
} from "../helper-hardhat-config";

const deployScoreProvider: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  log("----------------------------------------------------");
  log(
    "Deploying SimpleScoreProvider and waiting for confirmations with the power... "
  );
  log(`network: ${network.name}`);
  const simpleScoreProvider = await deploy("SimpleScoreProvider", {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`SimpleScoreProvider at ${simpleScoreProvider.address}`);
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(simpleScoreProvider.address, []);
  }
  return simpleScoreProvider.address;
};

const deployGovernorContract: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const scoreProviderAddress = await deployScoreProvider(hre);
  const governanceToken = await get("GovernanceToken");
  const timeLock = await get("TimeLock");
  const args = [
    governanceToken.address,
    timeLock.address,
    QUORUM_PERCENTAGE,
    VOTING_PERIOD,
    VOTING_DELAY,
    scoreProviderAddress,
  ];

  log("----------------------------------------------------");
  log("Deploying GovernorContract and waiting for confirmations...");
  const governorContract = await deploy("GovernorContract", {
    from: deployer,
    args,
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`GovernorContract at ${governorContract.address}`);
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(governorContract.address, args);
  }
};

export default deployGovernorContract;
deployGovernorContract.tags = ["all", "governor"];
