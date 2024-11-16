import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const address = mainWallet().address;

  const platform = await getContract("BOTPlatform");

  await sendTx(platform.registerEmail(address, "0xja.eth@gmail.com"), "registerEmail")
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
