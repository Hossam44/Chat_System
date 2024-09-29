## Challenge Overview

The goal of this challenge is to build a chat system with the following features:

- **Multiple Applications**: Each application is identified by a unique token.
- **Chat Management**: Each application can have multiple chats, identified by a sequential number starting from 1.
- **Message Handling**: Each chat can contain multiple messages, also identified by a sequential number starting from 1.

### Technical Requirements

- **RESTful Endpoints**: All API endpoints should follow REST principles.
- **Data Storage**: Use MySQL as the primary database.
- **Searching**: Implement ElasticSearch to enable searching through messages within a specific chat.
- **Containerization**: Use Docker to containerize the entire application.
- **Background Processing**: Utilize Sidekiq for creating chats and messages.
- **Cron Jobs**: Implement a scheduling mechanism (e.g., `rufus-scheduler`) to update the counts of chats and messages every 30 minutes.

# How To Run The Challenge
- First run 
 ``` bash
docker-compose build
``` 
- Then run
``` bash
docker-compose up
``` 

## Create APIs endpoints
-  create `applications` endopoints
-  create `chats` endopoints
-  create `messages` endopoints


# Chat System API Examples

## Applications

### Create Application
- **Endpoint**: `POST http://localhost:3000/api/v1/applications`
- **Request Body**:
```json
  {
    "name": "Application Name"
  }
```

### Get All Applications
- **Endpoint**: `GET http://localhost:3000/api/v1/applications`
- **Request Body**:


### Update Application
- **Endpoint**: `PUT http://localhost:3000/api/v1/applications/:token`
- **Request Body**:
```json
{
  "name": "Updated Application Name"
}
```

## Chats

### Create Chat
- **Endpoint**: `POST http://localhost:3000/api/v1/applications/{application_token}/chats`


### Get All Chats for a Specific Application
- **Endpoint**: `GET http://localhost:3000/api/v1/applications/:application_token/chats`


## Messages

### Create Message
- **Endpoint**: `POST http://localhost:3000/api/v1/applications/:application_token/chats/:chat_number/messages`
- **Request Body**:
```json
  {
    "body": "Message content"
  }
```


### Search Messages
- **Endpoint**: `GET http://localhost:3000/api/v1/applications/:application_token/chats/:chat_number/messages/search?query=search_term`


### Get All Messages for a Chat
- **Endpoint**: `GET http://localhost:3000/api/v1/applications/:application_token/chats/:chat_number/messages`

