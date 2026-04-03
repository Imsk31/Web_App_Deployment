import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Worker } from '../models/worker';
import { ConfigService } from './config.service';

@Injectable({ providedIn: 'root' })
export class WorkerService {

  constructor(
    private _httpClient: HttpClient,
    private _configService: ConfigService
  ) {}

  private get baseUrl(): string {
    return `${this._configService.getBackendApiUrl()}`;
  }

  getWorkers(): Observable<Worker[]> {
    return this._httpClient.get<Worker[]>(this.baseUrl).pipe(map(r => r));
  }

  saveWorkers(worker: Worker): Observable<Worker> {
    return this._httpClient.post<Worker>(this.baseUrl, worker);
  }

  getWorker(id: Number): Observable<Worker> {
    return this._httpClient.get<Worker>(`${this.baseUrl}/${id}`).pipe(map(r => r));
  }

  deleteWorker(id: Number): Observable<any> {
    return this._httpClient.delete(`${this.baseUrl}/${id}`, { responseType: 'text' });
  }
}