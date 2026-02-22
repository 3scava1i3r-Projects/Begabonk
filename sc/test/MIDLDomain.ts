import { expect } from "chai";
import { ethers } from "hardhat";

describe("MIDL Name Service", function () {
  let registry: any;
  let resolver: any;
  let domain: any;
  let owner: any;
  let addr1: any;
  let addr2: any;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("Should deploy all contracts", async function () {
      // Deploy Registry
      const MIDLRegistry = await ethers.getContractFactory("MIDLRegistry");
      registry = await MIDLRegistry.deploy();
      await registry.waitForDeployment();

      // Deploy Resolver
      const MIDLResolver = await ethers.getContractFactory("MIDLResolver");
      resolver = await MIDLResolver.deploy(await registry.getAddress());
      await resolver.waitForDeployment();

      // Deploy Domain
      const MIDLDomain = await ethers.getContractFactory("MIDLDomain");
      domain = await MIDLDomain.deploy(
        await registry.getAddress(),
        await resolver.getAddress()
      );
      await domain.waitForDeployment();

      // Set up TLD ownership - Domain contract must own .midl TLD
      const tldLabel = ethers.keccak256(ethers.toUtf8Bytes("midl"));
      await registry.setSubnodeOwner(ethers.ZeroHash, tldLabel, await domain.getAddress());

      expect(await domain.TLD()).to.equal("midl");
    });
  });

  describe("Name Registration", function () {
    it("Should register a name", async function () {
      const price = await domain.getPrice("alice");
      await expect(
        domain.connect(addr1).register("alice", { value: price })
      ).to.emit(domain, "NameRegistered");

      expect(await domain.getOwner("alice")).to.equal(addr1.address);
    });

    it("Should reject duplicate names", async function () {
      const price = await domain.getPrice("bob");
      await domain.connect(addr1).register("bob", { value: price });

      await expect(
        domain.connect(addr2).register("bob", { value: price })
      ).to.be.reverted;
    });

    it("Should reject names that are too short", async function () {
      await expect(
        domain.connect(addr1).register("ab", { value: ethers.parseEther("0.01") })
      ).to.be.reverted;
    });

    it("Should reject invalid names", async function () {
      await expect(
        domain.connect(addr1).register("test-name", { value: ethers.parseEther("0.01") })
      ).to.be.reverted;
    });

    it("Should charge correct price based on length", async function () {
      // 3 chars = 0.05 ETH
      expect(await domain.getPrice("abc")).to.equal(ethers.parseEther("0.05"));

      // 4 chars = 0.03 ETH
      expect(await domain.getPrice("abcd")).to.equal(ethers.parseEther("0.03"));

      // 5+ chars = 0.01 ETH
      expect(await domain.getPrice("abcde")).to.equal(ethers.parseEther("0.01"));
    });
  });

  describe("Name Transfer", function () {
    it("Should transfer a name", async function () {
      const price = await domain.getPrice("charlie");
      await domain.connect(addr1).register("charlie", { value: price });

      await expect(
        domain.connect(addr1).transferName(addr2.address, "charlie")
      ).to.emit(domain, "NameTransferred");

      expect(await domain.getOwner("charlie")).to.equal(addr2.address);
    });

    it("Should reject transfer from non-owner", async function () {
      const price = await domain.getPrice("dave");
      await domain.connect(addr1).register("dave", { value: price });

      await expect(
        domain.connect(addr2).transferName(addr1.address, "dave")
      ).to.be.reverted;
    });
  });

  describe("Availability Check", function () {
    it("Should return true for available names", async function () {
      expect(await domain.available("available")).to.equal(true);
    });

    it("Should return false for registered names", async function () {
      const price = await domain.getPrice("registered");
      await domain.connect(addr1).register("registered", { value: price });

      expect(await domain.available("registered")).to.equal(false);
    });
  });

  describe("Resolver", function () {
    it("Should set default address when registering", async function () {
      const price = await domain.getPrice("resolver");
      await domain.connect(addr1).register("resolver", { value: price });

      const node = await domain.getNameNode("resolver");
      expect(await resolver.addr(node)).to.equal(addr1.address);
    });

    it("Should allow setting text records", async function () {
      const price = await domain.getPrice("texttest");
      await domain.connect(addr1).register("texttest", { value: price });

      const node = await domain.getNameNode("texttest");
      await resolver.connect(addr1).setText(node, "email", "test@example.com");

      expect(await resolver.text(node, "email")).to.equal("test@example.com");
    });
  });

  describe("Withdrawal", function () {
    it("Should allow owner to withdraw", async function () {
      const price = await domain.getPrice("withdraw");
      await domain.connect(addr1).register("withdraw", { value: price });

      const balanceBefore = await ethers.provider.getBalance(owner.address);

      await domain.withdraw();

      const balanceAfter = await ethers.provider.getBalance(owner.address);
      expect(balanceAfter).to.be.greaterThan(balanceBefore);
    });
  });
});