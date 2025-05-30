import http from 'k6/http';
import { check, sleep } from 'k6';


export const options = {
  duration: '3m', // Test duration
  vus: 50, // Number of virtual users
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
  },
};

export default function () {
  const url = 'https://jsonplaceholder.typicode.com/posts'; // Replace with your target API endpoint
  const payload = JSON.stringify({
    title: 'foo',
    body: 'bar',
    userId: 1,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // Sending HTTP POST request
  const response = http.post(url, payload, params);

  // Validating response status
  check(response, {
    'status is 201': (r) => r.status === 201,
  });

  sleep(1); // Simulate real-world pacing between requests
}