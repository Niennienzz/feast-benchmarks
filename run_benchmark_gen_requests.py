import click
import json
import numpy as np
import base64


@click.command()
@click.option('--endpoints', multiple=True, help='Feature server endpoints')
@click.option('--features', default=250, help='Number of features')
@click.option('--entity-rows', default=1, help='Number of rows per request')
@click.option('--entity-keyspace', default=10**4, help='Entities range')
@click.option('--requests', default=10**3, help='Number of requests')
@click.option('--output', default='requests.json')
def generate_requests(endpoints, features, entity_rows, entity_keyspace, requests, output):
    vegeta_requests = []

    if features not in (50, 100, 150, 200, 250):
        raise ValueError("Number of features must be divisible one of (50, 100, 150, 200, 250)")

    if len(endpoints) < 1:
        raise ValueError("At least one endpoint must be provided")

    feature_service = f"feature_service_{features // 50 - 1}"

    for idx in range(requests):
        feast_request = {
            "feature_service": feature_service,
            "entities": {
                "entity": np.random.randint(0, entity_keyspace, entity_rows).tolist(),
            }
        }
        vegeta_request = {
            "method": "POST",
            "url": f"{endpoints[idx%len(endpoints)]}/get-online-features",
            "body": base64.encodebytes(json.dumps(feast_request).encode()).decode()
        }

        vegeta_requests.append(json.dumps(vegeta_request))

    with open(output, 'w') as f:
        f.write("\n".join(vegeta_requests))

    

if __name__ == '__main__':
    generate_requests()
