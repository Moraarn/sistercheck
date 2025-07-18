declare module 'node-fetch' {
  export default function fetch(url: string, options?: any): Promise<Response>;
  export class Response {
    ok: boolean;
    status: number;
    statusText: string;
    json(): Promise<any>;
    text(): Promise<string>;
  }
}

declare global {
  namespace Express {
    interface Request {
      user?: {
        _id?: string;
        patientId?: string;
        email?: string;
        type?: string;
        role?: string;
        [key: string]: any;
      };
    }
  }
}

export {}; 