import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE, walletAddresses} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const address = "0xde729290fa6f72dc9b802bb7cf12dad3f095da8d" // mainWallet().address;

  const token = await getContract("TestToken", "USDC")
  const platform = await getContract("BOTPlatform");

  // const allowance1 = await token.allowance(address, platform.address);
  // const allowance2 = await token.allowance("0xB043F6C111bBa68EDe5aD43E91753F66190deFb1", platform.address);
  //
  // console.log("Allowance 1:", allowance1.toString());
  // console.log("Allowance 2:", allowance2.toString());

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
