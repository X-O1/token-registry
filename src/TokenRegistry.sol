// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title TokenRegistry
 * @notice Maintains a list of approved tokens for your protocol
 * @dev Only the contract owner can add or remove tokens
 * @dev v2.0 will allow any DOA to add or remove tokens instead of contract owner
 * @custom:version v1.0
 */
contract TokenRegistry {
    error NOT_OWNER(address caller, address owner);
    error TOKEN_ALREADY_APPROVED(address tokenAddress);
    error TOKEN_NOT_APPROVED(address tokenAddress);
    error NOT_ACTIVE_CHAIN_ID(uint256 chainId, uint256 activeChainId);

    address immutable i_owner;
    uint256 immutable i_activeChainId;

    struct TokenDetails {
        address tokenAddress;
        uint256 chainId;
        address priceFeed;
    }

    mapping(address token => TokenDetails) public tokenDetails;
    mapping(address token => bool approved) public isApproved;

    event Token_Added_To_Registry(address indexed tokenAddress, uint256 indexed chainId, address indexed priceFeed);
    event Token_Removed_From_Registry(address indexed tokenAddress, uint256 indexed chainId, address indexed priceFeed);

    constructor() {
        i_owner = msg.sender;
        i_activeChainId = block.chainid;
    }

    modifier ownerOnly() {
        if (msg.sender != i_owner) {
            revert NOT_OWNER(msg.sender, i_owner);
        }
        _;
    }

    function addTokenToRegistry(address _tokenAddress, uint256 _chainId, address _priceFeed) external ownerOnly {
        if (_chainId != i_activeChainId) {
            revert NOT_ACTIVE_CHAIN_ID(_chainId, i_activeChainId);
        } else if (isApproved[_tokenAddress]) {
            revert TOKEN_ALREADY_APPROVED(_tokenAddress);
        } else {
            isApproved[_tokenAddress] = true;
            tokenDetails[_tokenAddress] =
                TokenDetails({tokenAddress: _tokenAddress, chainId: _chainId, priceFeed: _priceFeed});
        }

        emit Token_Added_To_Registry(_tokenAddress, _chainId, _priceFeed);
    }

    function removeTokenFromRegistry(address _tokenAddress, uint256 _chainId, address _priceFeed) external ownerOnly {
        if (_chainId != i_activeChainId) {
            revert NOT_ACTIVE_CHAIN_ID(_chainId, i_activeChainId);
        } else if (!isApproved[_tokenAddress]) {
            revert TOKEN_NOT_APPROVED(_tokenAddress);
        } else {
            isApproved[_tokenAddress] = false;
        }
        emit Token_Removed_From_Registry(_tokenAddress, _chainId, _priceFeed);
    }

    function checkIfTokenIsApproved(address _tokenAddress) public view returns (bool) {
        return isApproved[_tokenAddress];
    }

    function getTokenDetails(address _tokenAddress) public view returns (TokenDetails memory details) {
        if (isApproved[_tokenAddress]) return tokenDetails[_tokenAddress];
    }

    function getContractOwnerAddress() public view returns (address) {
        return i_owner;
    }
}
