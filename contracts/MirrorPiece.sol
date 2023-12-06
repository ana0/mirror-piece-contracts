// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NativeMetaTransaction.sol";
import "./ContextMixin.sol";

contract MirrorPiece is Ownable, IERC2981, ERC721, ContextMixin, NativeMetaTransaction {
    string public contractURI;
    string public storedBaseURI;
    address public controller;
    address public royaltyReceiver;
    uint256 public royaltyPercentage;

    mapping (bytes32 => bool) public mintcodes;
    uint256 public tokenHeight;

    modifier onlyOwnerOrController() {
        require(msg.sender == owner() || msg.sender == controller, "Must be owner or controller");
        _;
    }

    constructor (string memory name_, string memory symbol_, uint256 royaltyPercentage_) Ownable() ERC721(name_, symbol_) {
        _initializeEIP712(name_);
        royaltyReceiver = msg.sender;
        royaltyPercentage = royaltyPercentage_;
        tokenHeight = 0;
    }

    function setController(address _controller) public onlyOwner {
        controller = _controller;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        storedBaseURI = baseURI_;
    }

    function setMintCode(bytes32 code) public onlyOwner {
        mintcodes[code] = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return storedBaseURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setContractURI(string memory contractURI_) public onlyOwner {
        contractURI = contractURI_;
    }

    function setRoyaltyReceiver(address royaltyReceiver_) public onlyOwner {
        royaltyReceiver = royaltyReceiver_;
    }

    function setRoyaltyPercentage(uint256 royaltyPercentage_) public onlyOwner {
        royaltyPercentage = royaltyPercentage_;
    }

    function withdraw() public onlyOwner {
        bool sent = payable(owner()).send(address(this).balance);
        require(sent, "Failed to send Ether");
    }

    function mint(address to_, string memory code_) public onlyOwnerOrController {
        require(mintcodes[keccak256(abi.encodePacked(code_))]);
        _safeMint(to_, tokenHeight);
        mintcodes[keccak256(abi.encodePacked(code_))] = false;
        tokenHeight += 1;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {
      return (royaltyReceiver, (_salePrice * royaltyPercentage / 10000));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        override
        view
        virtual
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }

    /**
    * As another option for supporting trading without requiring meta transactions, override isApprovedForAll to whitelist OpenSea proxy accounts on Matic
    */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public override view returns (bool isOperator) {
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }
        
        return ERC721.isApprovedForAll(_owner, _operator);
    }
} 