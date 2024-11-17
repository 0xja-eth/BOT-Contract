import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther, parseUnits} from "ethers/lib/utils";

dotenv.config();

export async function deploy(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const address = mainWallet().address;

  const [token] = await makeContract("TestToken", "USDC", [
    "USD Coin", "USDC", "BOT", 6,
    "0x99166455989a868d5151799c716B3c1Be95D5114",
    "0x0Fe7773B44b2CFE4C9778616Db526359Ccda16bE",
    address,
    "0xe23fbAd6E1b18258AE1a964E17b1908e0690DdD4",
    0
  ])
  const [platform] = await makeContract("BOTPlatform");

  await sendTx(token.mint(address, parseUnits("10000000000", 6)), "mint");
  await sendTx(token.mint("0xdE729290Fa6F72Dc9B802bB7CF12dad3f095da8d", parseUnits("100000", 6)), "mint");
  await sendTx(token.mint("0xd0dD493E589B572365de10988C4d1F9E85a8B37a", parseUnits("100000", 6)), "mint");

  await sendTx(platform.changeToken(token.address), "changeToken");
  await sendTx(platform.changeEstimator(address), "changeEstimator");

  await sendTx(token.transfer(platform.address, parseUnits("10000", 6)), "transfer");
}

deploy(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
