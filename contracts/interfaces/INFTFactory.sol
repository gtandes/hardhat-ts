// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface INFTFactory {
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

    function initialize() external;

    function addAdmin(address admin) external;
    
    function removeAdmin(address admin) external;

    function submitProject(string memory projectDetails) external;

    function approveProject(address project) external;

    function rejectProject(address project) external;

    function createERC1155Collection(
        string memory name_,
        string memory symbol_,
        string memory description_,
        uint256 maxSupply_,
        uint96 royaltyFeeNumerator
    ) external;

    function createERC721Collection(
        string memory name_,
        string memory symbol_,
        string memory description_,
        uint256 maxSupply_,
        uint96 royaltyFeeNumerator
    ) external;

    function admins(address admin) external view returns (bool);
    
    function submittedProjects(address project) external view returns (Project memory);
    
    function approvedProjects(address project) external view returns (bool);
    
    function collectionOwners(address collection) external view returns (address);
}
