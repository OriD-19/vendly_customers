---
applyTo: '**/*.dart'
---

# Vendly API Integration Guide
This document provides instructions on how to integrate the Vendly API into your Dart application. Follow the steps below to set up and use the Vendly API effectively.

## API Endpoint

The main endpoint for all the operations is:

```
https://api.lacuponera.store
```

All the payloads and responses are in JSON format, and can be found in the [Vendly API Documentation](https://api.lacuponera.store/docs).
Also, you can check the openapi specification [here](https://api.lacuponera.store/openapi.json).

## Authentication
Authentication works with Bearer tokens, and includes the following endpoints:

- **POST /auth/login**: Authenticate a user and receive a Bearer token.kjw
- **POST /auth/register**: Register a new user account.
- **POST /auth/refresh**: Refresh an existing Bearer token.
- **POST /auth/logout**: Invalidate the current Bearer token.
- **GET /auth/me**: Retrieve information about the authenticated user.

## Users
The Users resource allows you to manage user accounts. The available endpoints are:

- **GET /users/me**: Retrieve information about the authenticated user.
- **GET /users**: Retrieve a list of all users.
- **GET /users/{id}**: Retrieve information about a specific user by ID.
- **DELETE /users/me**: Delete the authenticated user account.
- **GET /users/username/{username}**: Retrieve user information by username.

## Chat
The Chat resource allows you to manage chat messages, using WebSockets for real time interaction between customers and stores. The available endpoints are:

- **GET /chat/messages/{storeId}**: Retrieve chat messages for a specific store.
- **POST /chat/messages**: Send a new chat message.
- **POST /chat/messages/read**: Mark chat messages as read.
- **GET /chat/conversations**: Retrieve a list of chat conversations.
- **GET /chat/stores/{store_id}/conversations**: Retrieve conversations for a specific store.
- **GET /chat/conversations/{store_id}/messages**: Retrieve messages for a specific conversation with a specific store (one-to-one relationship between user and store).
- **DELETE /chat/messages/{message_id}**: Delete a specific chat message.
- **GET /chat/unread-count**: Retrieve the count of unread messages.


## Orders
The Orders resource allows you to manage customer orders. The available endpoints are:

- **GET /orders**: Retrieve a list of all orders.
- **GET /orders/{id}**: Retrieve information about a specific order by ID.
- **POST /orders**: Create a new order.
- **PUT /orders/{id}**: Update an existing order by ID.
- **DELETE /orders/{id}**: Delete a specific order by ID.
- **GET /orders/number/{order_number}**: Retrieve order information by order number.
- **POST /orders/{id}/cancel**: Cancel a specific order by ID.
- **GET /orders/customer/{customer_id}**: Retrieve orders for a specific customer by customer ID.


### Analytics
These endpoints are meant for store owners, so you can safely ignore them for the customer-side application

## Categories
The Categories resource allows you to manage product categories. The available endpoints are:

- **GET /categories**: Retrieve a list of all categories.
- **GET /categories/{id}**: Retrieve information about a specific category by ID.
- **POST /categories**: Create a new category.
- **PUT /categories/{id}**: Update an existing category by ID.
- **DELETE /categories/{id}**: Delete a specific category by ID.
- **GET /categories/name/{name}**: Retrieve category information by name.
- **GET /categories/{id}/products**: Retrieve products within a specific category by category ID.
- **GET /categories/name/{name}/products**: Retrieve products within a specific category by category name.
- **GET /categories/{id}/count**: Retrieve the count of products in a specific category by category ID.
- **GET /categories/{id}/statistics**: Retrieve statistics for a specific category by category ID.
- **GET /categories/all/with-counts**: Retrieve all categories along with their product counts.
- **GET /categories/search/{search_term}**: Search for categories by a search term.

## Stores
The Stores resource allows you to manage store information. For the customer-side application, you can use the following endpoints:

- **GET /stores**: Retrieve a list of all stores.
- **GET /stores/{id}**: Retrieve information about a specific store by ID.
- **GET /stores/search/**: Search for stores by a search term.
- **GET /stores/{store_id}/products**: Retrieve products for a specific store by store ID.
- **GET /stores/{store_id}/products/count**: Retrieve the count of products for a specific store by store ID.

## Products
The Products resource allows you to manage product information. For the customer-side application, you can use the following endpoints:

- **GET /products**: Retrieve a list of all products.
- **GET /products/{id}**: Retrieve information about a specific product by ID.
- **GET /products/{product_id}/images**: Retrieve images for a specific product by product ID.
- **GET /products/tags/{tag}**: Retrieve tags associated with products.
- **GET /products/search**: Search for products by a search term.
- **GET /products/by-tag/{tag}**: Retrieve products by a specific tag.