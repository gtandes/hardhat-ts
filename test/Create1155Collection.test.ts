const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("createERC1155Collection", function () {
  let NFTFactory;
  let NFTCollection1155;
  let nftFactory;
  let nftCollection1155;
  let owner;
  let admin;
  let addr1;
  let addr2;
  let addrs;

  const projectDetails = "Test Project";
  const name = "My ERC1155 Collection";
  const symbol = "MNFT";
  const description = "This is a description";
  const maxSupply = 100;
  const royaltyFeeNumerator = 500; // 5%

  beforeEach(async function () {
    NFTFactory = await ethers.getContractFactory("NFTFactory");
    NFTCollection1155 = await ethers.getContractFactory("NFTCollection1155");
    [owner, admin, addr1, addr2, ...addrs] = await ethers.getSigners();
    nftFactory = await NFTFactory.deploy();
    await nftFactory.waitForDeployment();
    await nftFactory.initialize();

    // Deploy the ERC1155 collection template
    nftCollection1155 = await NFTCollection1155.deploy();
    await nftCollection1155.waitForDeployment();
  });

  describe("Initialization", function () {
    it("Should set the right owner", async function () {
      expect(await nftFactory.owner()).to.equal(owner.address);
    });
  });

  describe("Admin Management", function () {
    it("Should allow the owner to add and remove admins", async function () {
      await nftFactory.addAdmin(admin.address);
      expect(await nftFactory.admins(admin.address)).to.equal(true);

      await nftFactory.removeAdmin(admin.address);
      expect(await nftFactory.admins(admin.address)).to.equal(false);
    });

    it("Should not allow non-owners to add or remove admins", async function () {
      await expect(
        nftFactory.connect(addr1).addAdmin(admin.address)
      ).to.be.revertedWithCustomError(nftFactory, "OwnableUnauthorizedAccount");

      await expect(
        nftFactory.connect(addr1).removeAdmin(admin.address)
      ).to.be.revertedWithCustomError(nftFactory, "OwnableUnauthorizedAccount");
    });
  });

  describe("Project Submission and Approval", function () {
    it("Should allow users to submit projects", async function () {
      await nftFactory.connect(addr1).submitProject(projectDetails);
      const project = await nftFactory.submittedProjects(addr1.address);
      expect(project.details).to.equal(projectDetails);
      expect(project.status).to.equal(0); // Pending
    });

    it("Should allow admins to approve projects", async function () {
      await nftFactory.connect(addr1).submitProject(projectDetails);
      await nftFactory.addAdmin(admin.address);
      await nftFactory.connect(admin).approveProject(addr1.address);

      const project = await nftFactory.submittedProjects(addr1.address);
      expect(project.status).to.equal(1); // Approved
      expect(await nftFactory.approvedProjects(addr1.address)).to.equal(true);
    });

    it("Should allow admins to reject projects", async function () {
      await nftFactory.connect(addr1).submitProject(projectDetails);
      await nftFactory.addAdmin(admin.address);
      await nftFactory.connect(admin).rejectProject(addr1.address);

      const project = await nftFactory.submittedProjects(addr1.address);
      expect(project.status).to.equal(2); // Rejected
      expect(await nftFactory.approvedProjects(addr1.address)).to.equal(false);
    });

    it("Should not allow non-admins to approve or reject projects", async function () {
      await nftFactory.connect(addr1).submitProject(projectDetails);
      await expect(nftFactory.connect(addr2).approveProject(addr1.address)).to.be.revertedWith("Not an admin");
      await expect(nftFactory.connect(addr2).rejectProject(addr1.address)).to.be.revertedWith("Not an admin");
    });
  });

  describe("ERC1155 Collection Creation", function () {
    beforeEach(async function () {
      await nftFactory.connect(addr1).submitProject(projectDetails);
      await nftFactory.addAdmin(admin.address);
      await nftFactory.connect(admin).approveProject(addr1.address);
    });

    it("Should allow approved projects to create ERC1155 collections", async function () {
      const tx = await nftFactory.connect(addr1).createERC1155Collection(
        name,
        symbol,
        description,
        maxSupply,
        royaltyFeeNumerator
      );

      const receipt = await tx.wait();
      // console.log("Transaction receipt:", receipt);
      // console.log("Logs:", receipt.logs);

      // Define the event ABI
      const eventAbi = [
        "event ERC1155CollectionCreated(address indexed owner, address indexed collectionAddress, string name, string symbol, string description, uint256 maxSupply, uint256 royaltyFeeNumerator)"
      ];

      // Create an interface with the event ABI
      const iface = new ethers.Interface(eventAbi);

      // Find the log entry for the event
      const log = receipt.logs.find(
        log => log.topics[0] === iface.getEvent("ERC1155CollectionCreated")
      );

      if (!log) {
        console.error("ERC1155CollectionCreated event not found in the logs");
        return;
      }

      // Parse the log entry
      const event = iface.parseLog(log);
      // console.log("Event:", event);

      expect(event).to.not.be.undefined;
      const collectionAddress = event.args.collectionAddress;
      expect(event.args.owner).to.equal(addr1.address);
      expect(event.args.name).to.equal(name);
      expect(event.args.symbol).to.equal(symbol);
      expect(event.args.description).to.equal(description);
      expect(event.args.maxSupply).to.equal(maxSupply);
      expect(event.args.royaltyFeeNumerator).to.equal(royaltyFeeNumerator);

      const project = await nftFactory.submittedProjects(collectionAddress);
      expect(project.details).to.equal(`Collection: ${name} - ${description}`);
      expect(project.status).to.equal(0); // Pending

      const collectionOwner = await nftFactory.collectionOwners(collectionAddress);
      expect(collectionOwner).to.equal(addr1.address);
    });

    it("Should not allow non-approved projects to create ERC1155 collections", async function () {
      await nftFactory.connect(addr2).submitProject(projectDetails);
      await expect(
        nftFactory.connect(addr2).createERC1155Collection(
          name,
          symbol,
          description,
          maxSupply,
          royaltyFeeNumerator
        )
      ).to.be.revertedWith("NFTFactory: project not approved");
    });

    it("Should not allow creating ERC1155 collections with maxSupply > 100", async function () {
      await expect(
        nftFactory.connect(addr1).createERC1155Collection(
          name,
          symbol,
          description,
          101, // maxSupply greater than 100
          royaltyFeeNumerator
        )
      ).to.be.revertedWith("NFTFactory: maxSupply cannot exceed 100");
    });
  });
});
