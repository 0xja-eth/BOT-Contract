import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE, walletAddresses} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const address = mainWallet().address;

  const platform = await getContract("BOTPlatform");

  const claimable = await platform.claimable(address);
  console.log("Claimable:", claimable.toString());

  const curTrip = await platform.currentTrips(address);
  console.log("Current Trip:", curTrip);

  const trip = await platform.trips(curTrip);
  console.log("Trip:", trip);
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
