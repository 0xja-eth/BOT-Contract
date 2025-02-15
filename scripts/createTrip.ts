import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther, parseUnits} from "ethers/lib/utils";
import {AddressZero} from "@ethersproject/constants";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const [token] = await makeContract("TestToken")
  const [platform] = await makeContract("BOTPlatform");

  const tripId = "trip2"; // Buffer.from("trip1");
  const startTime = Math.floor(new Date("2024-11-15 20:30").getTime() / 1000);
  const endTime = Math.floor(new Date("2024-11-17 1:32").getTime() / 1000);
  const value = parseUnits("3", 6);

  await sendTx(token.approve(platform.address, value), "approve");
  await sendTx(platform.startTrip(tripId, startTime, value, AddressZero), "startTrip");
  await sendTx(platform.estimateTrip(tripId, endTime), "estimateTrip");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
