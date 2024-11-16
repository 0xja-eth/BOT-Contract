import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const receiver = "0xCC968F87F7b7Cd5e3493cF87A7A6D2CaCC4E3d50";

  const token = await getContract("TestToken")
  const platform = await getContract("BOTPlatform");

  await sendTx(token.transfer(receiver || platform.address, parseEther("10000")), "transfer");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
