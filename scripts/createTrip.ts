import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const [token] = await makeContract("TestToken")
  const [platform] = await makeContract("BOTPlatform");

  const tripId = "123";
  const startTime = Math.floor(Date.now() / 1000);
  const value = parseEther("3");

  await sendTx(token.approve(platform.address, value), "approve");
  await sendTx(platform.startTrip(tripId, startTime, value), "startTrip");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
