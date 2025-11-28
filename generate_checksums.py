#!/usr/bin/env python3
"""
Generate SHA-256 checksums for attribution strings
"""

import hashlib

# Critical strings to validate
strings_to_hash = {
    '_S1': 'rajdeep-das',
    '_S2': 'rajdeepdas.india@gmail.com',
    '_S3': 'v1.0 • Built by RD',
    '_S4': '© 2025 • RD',
    '_S5': 'https://github.com/rajdeep-das',
}

print("Generating SHA-256 checksums for attribution strings...\n")

for var_name, string_value in strings_to_hash.items():
    # Compute SHA-256 hash
    hash_obj = hashlib.sha256(string_value.encode('utf-8'))
    hash_hex = hash_obj.hexdigest()

    print(f"{var_name}: '{string_value}'")
    print(f"  SHA-256: {hash_hex}")

    # Convert to hex array for Dart code
    hex_array = ', '.join([f"0x{hash_hex[i:i+2]}" for i in range(0, len(hash_hex), 2)])
    print(f"  Dart array: [{hex_array}]")
    print()

# Generate master key hash
print("\n=== MASTER KEY ===")
master_key = "RD-2025-SCREENX-7d4a9f2e"
master_hash = hashlib.sha256(master_key.encode('utf-8')).hexdigest()
print(f"Master Key: {master_key}")
print(f"Master Key SHA-256: {master_hash}")
print("\n⚠️  KEEP THIS KEY SECURE - Only you should have this key!")
print(f"   Key: {master_key}")
