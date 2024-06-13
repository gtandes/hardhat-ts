// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface INFTCollection1155 {
    event TokenMinted(
        address collection,
        address recipient,
        uint256 tokenId,
        string tokenUri
    );

    event BatchTokenMinted(
        address collection,
        address recipient,
        uint256[] tokenIds,
        string[] tokenUris
    );

    event TokenSalePriceSet(uint256 indexed tokenId, uint256 price);

    event TokenPutForSale(
        uint256 indexed tokenId,
        bool forSale,
        uint256 startTime,
        uint256 endTime
    );

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
        uint256 id,
        uint256 amount,
        bytes memory data,
        string memory tokenURI_
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        string[] memory tokenURIs
    ) external;

    function setTokenSalePrice(
        uint256 tokenId,
        uint256 price
    ) external;

    function setTokenForSale(
        uint256 tokenId,
        bool forSale,
        uint256 startTime,
        uint256 endTime
    ) external;

    function isTokenForSale(uint256 tokenId) external view returns (bool);

    function uri(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
