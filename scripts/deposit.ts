import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther, parseUnits} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const receiver = "0xd0dD493E589B572365de10988C4d1F9E85a8B37a";

  const token = await getContract("USDC")
  const platform = await getContract("BOTPlatform");

  await sendTx(token.transfer(receiver || platform.address, parseUnits("500", 6)), "transfer");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
