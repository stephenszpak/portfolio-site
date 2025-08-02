# DNS Configuration for www.stephenszpak.com

After successful deployment to Fly.io, you'll need to configure your DNS records to point your custom domain to the Fly.io infrastructure.

## Required DNS Records

### 1. Get Your Fly.io IP Addresses

Run this command to get your app's IP addresses:
```bash
fly ips list --app szpak-portfolio
```

### 2. Configure DNS Records

In your domain registrar's DNS settings (GoDaddy, Namecheap, Cloudflare, etc.), add these records:

#### A Records (IPv4)
```
Type: A
Name: stephenszpak.com (or @)
Value: [YOUR_FLY_IPV4_ADDRESS]
TTL: 300 (or minimum allowed)
```

#### AAAA Records (IPv6) - Optional but recommended
```
Type: AAAA  
Name: stephenszpak.com (or @)
Value: [YOUR_FLY_IPV6_ADDRESS]
TTL: 300 (or minimum allowed)
```

#### CNAME Record for www subdomain
```
Type: CNAME
Name: www
Value: stephenszpak.com
TTL: 300 (or minimum allowed)
```

## SSL Certificate Verification

After DNS propagation (usually 5-60 minutes), verify your SSL certificates:

```bash
# Check certificate status
fly certs show www.stephenszpak.com --app szpak-portfolio
fly certs show stephenszpak.com --app szpak-portfolio

# Check certificate health
fly certs check www.stephenszpak.com --app szpak-portfolio
fly certs check stephenszpak.com --app szpak-portfolio
```

## Testing Your Deployment

1. **Check DNS Propagation**:
   ```bash
   dig stephenszpak.com
   dig www.stephenszpak.com
   ```

2. **Test HTTPS**:
   ```bash
   curl -I https://www.stephenszpak.com
   curl -I https://stephenszpak.com
   ```

3. **Monitor Application**:
   ```bash
   fly status --app szpak-portfolio
   fly logs --app szpak-portfolio
   ```

## Troubleshooting

### Certificate Issues
- Ensure DNS records are properly configured
- Wait for DNS propagation (up to 48 hours in rare cases)
- Check that your domain registrar allows external DNS management

### Common Commands
```bash
# Restart the application
fly apps restart szpak-portfolio

# Update deployment
fly deploy --app szpak-portfolio

# View recent logs
fly logs --app szpak-portfolio -n 100

# Scale application (if needed)
fly scale count 1 --app szpak-portfolio
```

## Expected Timeline

1. **DNS Configuration**: 5 minutes
2. **DNS Propagation**: 5-60 minutes
3. **SSL Certificate Issuance**: 1-10 minutes after DNS propagation
4. **Full Site Availability**: Usually within 1 hour of DNS configuration

Your portfolio will be live at:
- https://www.stephenszpak.com (primary)
- https://stephenszpak.com (redirect to www)
- https://szpak-portfolio.fly.dev (Fly.io default URL)