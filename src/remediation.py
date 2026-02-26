import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    print("🔍 Iniciando Auditoría Continua de Security Groups...")
    
    # 1. Buscar todos los SGs que tengan el puerto 22 abierto al mundo
    try:
        sgs = ec2.describe_security_groups(
            Filters=[
                {'Name': 'ip-permission.from-port', 'Values': ['22']},
                {'Name': 'ip-permission.to-port', 'Values': ['22']},
                {'Name': 'ip-permission.cidr', 'Values': ['0.0.0.0/0']}
            ]
        )['SecurityGroups']

        if not sgs:
            print("✅ Todo limpio. No se encontraron brechas de seguridad.")
            return

        for sg in sgs:
            sg_id = sg['GroupId']
            print(f"🛡️ Remediando brecha en: {sg_id}")
            
            ec2.revoke_security_group_ingress(
                GroupId=sg_id,
                IpProtocol='tcp',
                FromPort=22,
                ToPort=22,
                CidrIp='0.0.0.0/0'
            )
            print(f"✨ Puerto 22 revocado con éxito en {sg_id}")
            
    except Exception as e:
        print(f"❌ Error en la auditoría: {str(e)}")
