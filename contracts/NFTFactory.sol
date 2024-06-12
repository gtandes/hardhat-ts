// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./NFTCollection1155.sol";
import "./NFTCollection721.sol";

contract NFTFactory is Initializable, OwnableUpgradeable, ReentrancyGuard {
    event ProjectSubmitted(address indexed submitter, string projectDetails);
    event ProjectApproved(address indexed project, address indexed approver);
    event ProjectRejected(address indexed project, address indexed rejecter);

    event ERC1155CollectionCreated(
        address indexed owner,
        address indexed collectionAddress,
        string name,
        string symbol,
        string description,
        uint256 maxSupply,
        uint256 royaltyFeeNumerator
    );

    event ERC721CollectionCreated(
        address indexed owner,
        address indexed collectionAddress,
        string name,
        string symbol,
        string description,
        uint256 maxSupply,
        uint256 royaltyFeeNumerator
    );

    enum ProjectStatus {
        Pending,
        Approved,
        Rejected
    }

    struct Project {
        string details;
        ProjectStatus status;
    }

    mapping(address => bool) public admins;
    mapping(address => Project) public submittedProjects;
    mapping(address => bool) public approvedProjects;
    mapping(address => address) public collectionOwners;

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner(), "Not an admin");
        _;
    }

    function addAdmin(address admin) public onlyOwner {
        admins[admin] = true;
    }

    function removeAdmin(address admin) public onlyOwner {
        admins[admin] = false;
    }

    function submitProject(string memory projectDetails) public {
        submittedProjects[msg.sender] = Project({
            details: projectDetails,
            status: ProjectStatus.Pending
        });

        emit ProjectSubmitted(msg.sender, projectDetails);
    }

    function approveProject(address project) public onlyAdmin {
        require(
            submittedProjects[project].status == ProjectStatus.Pending,
            "NFTFactory: project is not pending"
        );
        submittedProjects[project].status = ProjectStatus.Approved;
        approvedProjects[project] = true;
        emit ProjectApproved(project, msg.sender);
    }

    function rejectProject(address project) public onlyAdmin {
        require(
            submittedProjects[project].status == ProjectStatus.Pending,
            "NFTFactory: project is not pending"
        );
        submittedProjects[project].status = ProjectStatus.Rejected;
        emit ProjectRejected(project, msg.sender);
    }

    function createERC1155Collection(
        string memory name_,
        string memory symbol_,
        string memory description_,
        uint256 maxSupply_,
        uint96 royaltyFeeNumerator
    ) public nonReentrant {
        require(maxSupply_ <= 100, "NFTFactory: maxSupply cannot exceed 100");
        require(
            approvedProjects[msg.sender],
            "NFTFactory: project not approved"
        );

        NFTCollection1155 collection = new NFTCollection1155();

        collection.initialize(
            name_,
            symbol_,
            description_,
            maxSupply_,
            msg.sender,
            royaltyFeeNumerator
        );

        submittedProjects[address(collection)] = Project({
            details: string(
                abi.encodePacked("Collection: ", name_, " - ", description_)
            ),
            status: ProjectStatus.Pending
        });

        collectionOwners[address(collection)] = msg.sender;

        emit ERC1155CollectionCreated(
            msg.sender,
            address(collection),
            name_,
            symbol_,
            description_,
            maxSupply_,
            royaltyFeeNumerator
        );

        emit ProjectSubmitted(
            address(collection),
            string(abi.encodePacked("Collection: ", name_, " - ", description_))
        );
    }

    function createERC721Collection(
        string memory name_,
        string memory symbol_,
        string memory description_,
        uint256 maxSupply_,
        uint96 royaltyFeeNumerator
    ) public nonReentrant {
        require(maxSupply_ <= 100, "NFTFactory: maxSupply cannot exceed 100");
        require(
            approvedProjects[msg.sender],
            "NFTFactory: project not approved"
        );

        NFTCollection721 collection = new NFTCollection721();

        collection.initialize(
            name_,
            symbol_,
            description_,
            maxSupply_,
            msg.sender,
            royaltyFeeNumerator
        );

        submittedProjects[address(collection)] = Project({
            details: string(
                abi.encodePacked("Collection: ", name_, " - ", description_)
            ),
            status: ProjectStatus.Pending
        });

        collectionOwners[address(collection)] = msg.sender;

        emit ERC721CollectionCreated(
            msg.sender,
            address(collection),
            name_,
            symbol_,
            description_,
            maxSupply_,
            royaltyFeeNumerator
        );

        emit ProjectSubmitted(
            address(collection),
            string(abi.encodePacked("Collection: ", name_, " - ", description_))
        );
    }
}
