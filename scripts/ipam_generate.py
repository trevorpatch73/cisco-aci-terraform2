import pandas as pd
from ipaddress import ip_network
from pathlib import Path

def generate_all_ips_with_network_broadcast(df, existing_df=None):
    all_rows = []  # List to hold all rows for final DataFrame

    # Iterate over each row in the original dataframe
    for _, row in df.iterrows():
        network = ip_network(f"{row['NETWORK_PREFIX']}/{row['NETWORK_CIDR']}", strict=False)

        # Check if the network prefix already exists in the final CSV to avoid duplicates
        if existing_df is not None:
            if any(existing_df['NETWORK_PREFIX'] == row['NETWORK_PREFIX']) and any(existing_df['NETWORK_CIDR'] == row['NETWORK_CIDR']):
                continue  # Skip this prefix as it already exists

        # Create rows for network and broadcast addresses with specified values
        network_row = row.copy()
        broadcast_row = row.copy()

        # Set network and broadcast addresses
        network_row['NETWORK_IP'] = str(network.network_address)
        network_row['HOSTNAME'] = 'network'
        broadcast_row['NETWORK_IP'] = str(network.broadcast_address)
        broadcast_row['HOSTNAME'] = 'broadcast'

        # Set specified values for DOMAIN_NAME, APPLICATION, ROLE
        for r in [network_row, broadcast_row]:
            r['DOMAIN_NAME'] = 'internal.das'
            r['APPLICATION'] = 'infra'
            r['ROLE'] = 'ntwk'

        # Add network and broadcast rows to the list
        all_rows.append(network_row)
        all_rows.append(broadcast_row)

        # Generate all host IPs in the subnet and add to list
        for ip in network.hosts():
            host_row = row.copy()
            host_row['NETWORK_IP'] = str(ip)
            # Keep HOSTNAME, DOMAIN_NAME, APPLICATION, ROLE fields empty
            all_rows.append(host_row)

    # Convert all rows to a DataFrame
    all_ips_df = pd.DataFrame(all_rows)
    return all_ips_df

# Load the original CSV file
file_path = './data/ipam_cidrs.csv'
df = pd.read_csv(file_path)

# Check if the final CSV already exists
final_csv_path = './data/ipam_hosts.csv'
final_df = None
if Path(final_csv_path).exists():
    final_df = pd.read_csv(final_csv_path)

# Generate the DataFrame with all IPs including network and broadcast
all_ips_df = generate_all_ips_with_network_broadcast(df, existing_df=final_df)

# If the final CSV exists, we append; otherwise, we create a new file
if final_df is not None:
    final_df = pd.concat([final_df, all_ips_df]).drop_duplicates(subset=['NETWORK_PREFIX', 'NETWORK_CIDR', 'NETWORK_IP'])
else:
    final_df = all_ips_df

# Reorder columns to match the desired order
final_df = final_df[
    [
     'NETWORK_PREFIX', 
     'NETWORK_CIDR', 
     'NETWORK_IP', 
     'HOSTNAME',
     'DOMAIN_NAME', 
     'APPLICATION', 
     'ROLE', 
     'LOCATION', 
     'ENVIRONMENT', 
     'TENANT', 
     'ZONE'
    ]
]

# Save the updated dataframe to a CSV file
final_df.to_csv(final_csv_path, index=False)

print(f"CSV file has been saved to {final_csv_path}")
