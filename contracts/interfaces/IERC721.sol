// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface INFTCollection721 {
    struct SaleInfo {
        bool forSale;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
    }

    // Events
    event TokenMinted(
        address indexed collection,
        address indexed recipient,
        uint256 indexed tokenId,
        string tokenUri
    );

    event TokenSalePriceSet(uint256 indexed tokenId, uint256 price);

    event TokenPutForSale(
        uint256 indexed tokenId,
        bool forSale,
        uint256 startTime,
        uint256 endTime
    );

    // Functions
    function description() external view returns (string memory);

    function maxSupply() external view returns (uint256);

    function totalMinted() external view returns (uint256);

    function tokenSalePrice(uint256 tokenId) external view returns (uint256);

    function tokenForSale(uint256 tokenId) external view returns (bool);

    function listingStartTime(uint256 tokenId) external view returns (uint256);

    function listingEndTime(uint256 tokenId) external view returns (uint256);

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory description_,
        uint256 maxSupply_,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    ) external;

    function mint(
        address to,
        uint256 tokenId,
        string memory tokenURI_
    ) external;

    function setTokenSalePrice(uint256 tokenId, uint256 price) external;

    function setTokenForSale(
        uint256 tokenId,
        bool forSale,
        uint256 startTime,
        uint256 endTime
    ) external;

    function isTokenForSale(uint256 tokenId) external view returns (bool);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
