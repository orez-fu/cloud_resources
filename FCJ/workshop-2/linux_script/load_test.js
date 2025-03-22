import http from 'k6/http';
import { check, sleep } from 'k6';

// Load testing configuration
export let options = {
  vus: 50, // Virtual users
  duration: '3m', // Test duration
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
  },
};

export default function () {
  // Specify the URL of the website to test
  const url = 'https://jsonplaceholder.typicode.com/posts'; // Replace with the actual URL
  const payload = JSON.stringify({
    title: 'testing',
    body: 'conducting load test',
    userId: 1,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // Make a GET request
  const res = http.post(url, payload, params);

  // Check the response
  check(res, {
    'is status 201': (r) => r.status === 201
  });

  // Sleep for a random duration between requests to simulate real users
  sleep(Math.random() * 2);
}