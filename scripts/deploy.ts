import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function deploy(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const address = mainWallet().address;

  const [token] = await makeContract("TestToken")
  const [platform] = await makeContract("BOTPlatform");

  await sendTx(platform.changeToken(token.address), "changeToken");
  await sendTx(platform.changeEstimator(address), "changeEstimator");

  await sendTx(token.transfer(platform.address, parseEther("10000")), "transfer");
}

deploy(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
