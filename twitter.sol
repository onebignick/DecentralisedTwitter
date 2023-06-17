// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Twitter {
    struct Tweet {
        address author;
        string content;
        uint256 timestamp;
    }
    
    struct User {
        mapping(uint256 => bool) follows;
        mapping(uint256 => uint256) tweetIds;
        uint256 tweetCount;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => Tweet) public tweets;
    uint256 public tweetCount;
    
    event TweetPosted(address indexed author, uint256 indexed tweetId, string content, uint256 timestamp);
    event TweetUpdated(address indexed author, uint256 indexed tweetId, string newContent, uint256 timestamp);
    
    function postTweet(string memory _content) public {
        require(bytes(_content).length > 0, "Tweet content should not be empty.");
        
        tweetCount++;
        tweets[tweetCount] = Tweet(msg.sender, _content, block.timestamp);
        
        users[msg.sender].tweetIds[users[msg.sender].tweetCount] = tweetCount;
        users[msg.sender].tweetCount++;
        
        emit TweetPosted(msg.sender, tweetCount, _content, block.timestamp);
    }
    
    function updateTweet(uint256 _tweetId, string memory _newContent) public {
        require(_tweetId <= tweetCount, "Invalid tweet ID.");
        require(tweets[_tweetId].author == msg.sender, "You can only update your own tweets.");
        require(bytes(_newContent).length > 0, "New tweet content should not be empty.");
        
        tweets[_tweetId].content = _newContent;
        tweets[_tweetId].timestamp = block.timestamp;
        
        emit TweetUpdated(msg.sender, _tweetId, _newContent, block.timestamp);
    }
    
    function follow(address _user) public {
        require(_user != address(0), "Invalid user address.");
        require(_user != msg.sender, "You cannot follow yourself.");
        
        users[msg.sender].follows[uint256(uint160(_user))] = true;
    }
    
    function getFeed(address _user) public view returns (Tweet[] memory) {
        require(_user != address(0), "Invalid user address.");
        
        User storage user = users[_user];
        uint256 totalTweets = user.tweetCount;
        
        for (uint256 i = 0; i < totalTweets; i++) {
            if (user.follows[uint256(uint160(_user))]) {
                totalTweets++;
            }
        }
        
        uint256 count = 0;
        Tweet[] memory feed = new Tweet[](10);
        
        for (uint256 i = totalTweets; i > 0 && count < 10; i--) {
            uint256 tweetId = user.tweetIds[i - 1];
            
            if (tweetId != 0) {
                feed[count] = tweets[tweetId];
                count++;
            }
        }
        
        return feed;
    }
}
