import boto3

def lambda_handler(event, context):
    # Variables
    region = "us-east-2"
    route_table_id1 = get_route_table_id_by_tag("example9-dev-vpc100-private-subnet-rt1", region)
    route_table_id2 = get_route_table_id_by_tag("example9-dev-vpc100-private-subnet-rt2", region)
    palo1_eth1_id   = get_interface_id_by_tag("example9-dev-palo1-eth1", region)
    palo1_eth2_id   = get_interface_id_by_tag("example9-dev-palo1-eth2", region)
    eip_id1         = get_eip_id_by_tag("example9-dev-eip-ubuntu1", region)
    eip_id2         = get_eip_id_by_tag("example9-dev-eip-ubuntu2", region)
    cidr_block      = "0.0.0.0/0"
    palo1_eth1_ip1  = "10.100.11.101"
    palo1_eth1_ip2  = "10.100.11.102"
    
    delete_route(cidr_block, route_table_id1, region)
    delete_route(cidr_block, route_table_id2, region)

    add_route(cidr_block, palo1_eth2_id, route_table_id1, region)
    add_route(cidr_block, palo1_eth2_id, route_table_id2, region)
    associate_eip(eip_id1, region, palo1_eth1_id , palo1_eth1_ip1)
    associate_eip(eip_id2, region, palo1_eth1_id , palo1_eth1_ip2)
     

def disassociate_eip(allocation_id,region):
    # Replace 'region_name' with the appropriate AWS region
    ec2_client = boto3.client('ec2', region_name=region)
    association_id = None
    try:
        response = ec2_client.describe_addresses(
            AllocationIds=[allocation_id]
        )
        association_id = response['Addresses'][0]['AssociationId']
        print(f"Retrieved association ID: {association_id} for EIP:{allocation_id}")
    except Exception as e:
        print("Error retrieving association ID:", str(e))
        return None

    try:
        response = ec2_client.disassociate_address(
            AssociationId=association_id,
        )
        print(f"Disassociated successfully EIP:{allocation_id}")
    except Exception as e:
        print("Error disassociating EIP:", str(e))   
        return None
        
    return response

def associate_eip(allocation_id, region, interface_id, private_ip):
    ec2_client = boto3.client('ec2', region_name=region)
    
    try:
        response = ec2_client.associate_address(
            NetworkInterfaceId=interface_id,
            PrivateIpAddress=private_ip,
            AllocationId=allocation_id
        )
        print("EIP associated successfully")
    except Exception as e:
        print("Error associating EIP:", str(e))        

def delete_route(cidr_block, route_table_id, region):
    ec2_client = boto3.client('ec2', region_name=region)
    
    try:
        response = ec2_client.delete_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock=cidr_block
        )
        print(f"Route {cidr_block} deleted successfully from route table {route_table_id}")
    except Exception as e:
        print("Error deleting route:", str(e))

def add_route(cidr_block, interface_id, route_table_id, region):
    ec2_client = boto3.client('ec2', region_name=region)

    try:
        response = ec2_client.create_route(
            RouteTableId=route_table_id,
            DestinationCidrBlock=cidr_block,
            NetworkInterfaceId=interface_id
        )
        print(f"Route {cidr_block} added successfully to route table {route_table_id} with interface id:{interface_id}")
    except Exception as e:
        print("Error adding route:", str(e))            
        
def get_route_table_id_by_tag(tagstring, region):
    ec2_client = boto3.client('ec2', region_name=region)
    
    # Retrieve all route tables
    response = ec2_client.describe_route_tables()
    
    # Search for the route table with a matching substring in the tag value
    for route_table in response['RouteTables']:
        for tag in route_table['Tags']:
            if tag['Key'] == 'Name' and tagstring in tag['Value']:
                print(f"Route table lookup is successfull based on {tagstring} route table id {route_table['RouteTableId']}")
                return route_table['RouteTableId']
    
    # Exit if no route table is found
    raise Exception(f"Route table lookup failed based on {tagstring}")
    
def get_interface_id_by_tag(tagstring, region):
    ec2_client = boto3.client('ec2')
    
    # Retrieve all network interfaces
    response = ec2_client.describe_network_interfaces()
    
    # Search for the network interface with the specified tag
    for network_interface in response['NetworkInterfaces']:
        for tag in network_interface['TagSet']:
            if tag['Key'] == 'Name' and tagstring in tag['Value'] :
                print(f"Interface Id is successfull based on {tagstring} Interface id {network_interface['NetworkInterfaceId']}")
                return network_interface['NetworkInterfaceId']
    
    # Exit if no network interface is found
    raise Exception(f"Interface Id lookup failed based on {tagstring}")

def get_eip_id_by_tag(tagstring, region):
    ec2_client = boto3.client('ec2')
    
    # Retrieve all Elastic IPs
    response = ec2_client.describe_addresses()
    
    # Search for the Elastic IP with the specified tag
    for eip in response['Addresses']:
        if 'Tags' in eip:
            for tag in eip['Tags']:
                if tag['Key'] == 'Name' and tagstring in tag['Value'] :
                    print(f"EIP Id is successfull based on {tagstring} EIP id {eip['AllocationId']}")
                    return eip['AllocationId']
    
    # Exit if no Elastic IP is found
    raise Exception(f"EIP Id lookup failed based on {tagstring}")