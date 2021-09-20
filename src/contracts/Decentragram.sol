pragma solidity ^0.5.0;

contract Decentragram {
  string public name = "Decentragram";

  // Store images
  uint public imageCount = 0;
  mapping(uint => Image) public images;

  // struct allows us to create a type
  struct Image {
    uint id;
    string hash;
    string description;
    uint tipAmount;
    address payable author; 
  }

  // event store args passed in transaction logs
  event ImageCreated(
    uint id, 
    string hash,
    string description,
    uint tipAmount,
    address payable author
  );

  event ImageTipped(
    uint id,
    string hash,
    string description,
    uint tipAmount,
    address payable author
  );

  // Create images
  function uploadImage(string memory _imgHash, string memory _desc) public {
   // Make sure the image hash exists
    require(bytes(_imgHash).length > 0);
    // Make sure image description exists
    require(bytes(_desc).length > 0);
    // Make sure uploader address exists
    require(msg.sender!=address(0));

    // Increment image id
    imageCount ++;

    // Add Image to the contract
    images[imageCount] = Image(imageCount, _imgHash, _desc, 0, msg.sender);
    // Trigger an event
    emit ImageCreated(imageCount, _imgHash, _desc, 0, msg.sender);
  }

  // Tip images
  function tipImageOwner (uint _id) public payable {
    // Make sure the id is valid
    require(_id > 0 && _id <= imageCount);
    // Fetch the image
    Image memory _image = images[_id];
    // Fetch the author
    address payable _author = _image.author;
    // Pay the author by sending them Ether
    address(_author).transfer(msg.value);
    // Increment the tip amount
    _image.tipAmount = _image.tipAmount + msg.value;
    // Update the image
    images[_id] = _image;
    // Trigger an event
    emit ImageTipped(_id, _image.hash, _image.description, _image.tipAmount, _author);
  }
}