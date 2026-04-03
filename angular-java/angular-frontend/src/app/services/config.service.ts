import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class ConfigService {
  private config: { backendApiUrl: string } = { backendApiUrl: '' };

  constructor(private http: HttpClient) {}

  load(): Promise<void> {
    return this.http
      .get<{ backendApiUrl: string }>('/assets/config.json')
      .toPromise()
      .then(cfg => { this.config = cfg!; });
  }

  getBackendApiUrl(): string {
    return this.config.backendApiUrl;
  }
}