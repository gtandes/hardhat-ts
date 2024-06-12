// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTCollection1155 is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC2981Upgradeable,
    ReentrancyGuard
{
    string public name;
    string public symbol;
    string public description;
    uint256 public maxSupply;
    uint256 public totalMinted;

    uint256 public constant MIN_PRICE = 0;
    uint256 public constant MAX_PRICE = 250 * 10 ** 18; // 250 Ether in wei (equivalent to $1,000,000 at $4,000/Ether)

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public tokenSalePrice;
    mapping(uint256 => bool) public tokenForSale;
    mapping(uint256 => uint256) public listingStartTime;
    mapping(uint256 => uint256) public listingEndTime;

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
    ) public initializer {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        __ERC2981_init();
        // __ReentrancyGuard_init();
        name = name_;
        symbol = symbol_;
        description = description_;
        maxSupply = maxSupply_;
        _setDefaultRoyalty(royaltyReceiver, royaltyFeeNumerator);
    }

    modifier supplyCheck(uint256 amount) {
        require(
            totalMinted + amount <= maxSupply,
            "NFTCollection1155: Exceeds max supply"
        );
        _;
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
        string memory tokenURI_
    ) public onlyOwner supplyCheck(amount) nonReentrant {
        _mint(to, id, amount, data);
        _setTokenURI(id, tokenURI_);
        totalMinted += amount;

        emit TokenMinted(address(this), to, id, tokenURI_);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        string[] memory tokenURIs
    ) public onlyOwner nonReentrant {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        require(
            totalMinted + totalAmount <= maxSupply,
            "NFTCollection1155: Exceeds max supply"
        );

        _mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++) {
            _setTokenURI(ids[i], tokenURIs[i]);
        }
        totalMinted += totalAmount;

        emit BatchTokenMinted(address(this), to, ids, tokenURIs);
    }

    function setTokenSalePrice(
        uint256 tokenId,
        uint256 price
    ) public onlyOwner nonReentrant {
        require(
            price >= MIN_PRICE && price <= MAX_PRICE,
            "NFTCollection1155: Sale price must be between 0 and 250 Ether (equivalent to $1,000,000 at $4,000/Ether)"
        );
        tokenSalePrice[tokenId] = price;
        emit TokenSalePriceSet(tokenId, price);
    }

    function setTokenForSale(
        uint256 tokenId,
        bool forSale,
        uint256 startTime,
        uint256 endTime
    ) public onlyOwner nonReentrant {
        require(startTime < endTime, "Invalid listing time");
        tokenForSale[tokenId] = forSale;
        listingStartTime[tokenId] = startTime;
        listingEndTime[tokenId] = endTime;
        emit TokenPutForSale(tokenId, forSale, startTime, endTime);
    }

    function isTokenForSale(uint256 tokenId) public view returns (bool) {
        return
            tokenForSale[tokenId] &&
            block.timestamp >= listingStartTime[tokenId] &&
            block.timestamp <= listingEndTime[tokenId];
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal {
        _tokenURIs[tokenId] = tokenURI_;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155Upgradeable, ERC2981Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
