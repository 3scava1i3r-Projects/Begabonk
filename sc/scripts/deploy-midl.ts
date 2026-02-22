import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying MIDL Name Service contracts...\n");
  console.log(`Deployer: ${deployer.address}\n`);

  // Deploy Registry
  console.log("1. Deploying MIDLRegistry...");
  const MIDLRegistry = await ethers.getContractFactory("MIDLRegistry");
  const registry = await MIDLRegistry.deploy();
  await registry.waitForDeployment();
  const registryAddress = await registry.getAddress();
  console.log(`   MIDLRegistry deployed to: ${registryAddress}\n`);

  // Deploy Resolver
  console.log("2. Deploying MIDLResolver...");
  const MIDLResolver = await ethers.getContractFactory("MIDLResolver");
  const resolver = await MIDLResolver.deploy(registryAddress);
  await resolver.waitForDeployment();
  const resolverAddress = await resolver.getAddress();
  console.log(`   MIDLResolver deployed to: ${resolverAddress}\n`);

  // Deploy Domain NFT contract
  console.log("3. Deploying MIDLDomain...");
  const MIDLDomain = await ethers.getContractFactory("MIDLDomain");
  const domain = await MIDLDomain.deploy(registryAddress, resolverAddress);
  await domain.waitForDeployment();
  const domainAddress = await domain.getAddress();
  console.log(`   MIDLDomain deployed to: ${domainAddress}\n`);

  // Setup: Transfer ownership of TLD node to Domain contract
  console.log("4. Setting up TLD ownership...");
  const tldLabel = ethers.keccak256(ethers.toUtf8Bytes("midl"));
  
  // Set the domain contract as the owner of the .midl TLD
  const tx = await registry.setSubnodeOwner(ethers.ZeroHash, tldLabel, domainAddress);
  await tx.wait();
  console.log(`   Domain contract set as owner of .midl TLD\n`);

  console.log("=".repeat(50));
  console.log("Deployment Summary:");
  console.log("=".repeat(50));
  console.log(`Registry:  ${registryAddress}`);
  console.log(`Resolver:  ${resolverAddress}`);
  console.log(`Domain:    ${domainAddress}`);
  console.log("=".repeat(50));
  console.log("\nNext steps:");
  console.log("1. Verify contracts on block explorer");
  console.log("2. Update frontend with contract addresses");
  console.log("3. Test registration flow");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
