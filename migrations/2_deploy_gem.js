const ROLE_TOKEN_CREATOR = 0x00040000;
const ROLE_COUPON_MANAGER = 0x00000100;

const Gem = artifacts.require("./GemERC721");
const Sale = artifacts.require("./CouponSale");
const AddressUtils = artifacts.require("./AddressUtils");
const StringUtils = artifacts.require("./StringUtils");

module.exports = async function(deployer, network, accounts) {
	if(network === "test") {
		console.log("[deploy gem] test network - skipping the migration script");
		return;
	}
	if(network === "coverage") {
		console.log("[deploy gem] coverage network - skipping the migration script");
		return;
	}

	let chest = "0xc352f692f55def49f0b736ec1f7ca0f862eabd23"; // MainNet Chest Wallet
	let beneficiary = "0xe0123204873fd29a29aef3f99faf1b1c45fe3b1e"; // MainNet MultiSig
/*
	if(network === "development") {
		beneficiary = "0xb4e8e4f7e6024b37ed2584e8c86b2917dae9a2da"; // Rinkeby MultiSig
		chest = "0xaF8413e5785d63694cF562Cf2dDA9B59Ff00E0FD"; // Rinkeby Chest Wallet
	}
*/

	await deployer.deploy(AddressUtils);
	await deployer.link(AddressUtils, Gem);

	await deployer.deploy(StringUtils);
	await deployer.link(StringUtils, Gem);

	await deployer.deploy(Gem);

	const gem = await Gem.deployed();
//	await gem.updateFeatures(0xFFFFFFFF);

	await deployer.deploy(Sale, gem.address, chest, beneficiary);

	const sale = await Sale.deployed();
	await gem.addOperator(sale.address, ROLE_TOKEN_CREATOR);

	await sale.addOperator("0x501E13C2aE8D9232B88F63E87DFA1dF28103aCb6", ROLE_COUPON_MANAGER); // John
	await sale.addOperator("0x391B9254BE4F56dadF57905113Dfb88a3bf8f141", ROLE_COUPON_MANAGER); // Myke

	console.log("___________________________________________________");
	console.log("gem:        " + gem.address);
	console.log("sale:       " + sale.address);

};
